import base64
import datetime as dt
import gzip
import json
import logging
import os
from typing import Any
from urllib import parse
from urllib import error, request


logger = logging.getLogger()
logger.setLevel(logging.INFO)

FLOW_LOG_FIELDS = json.loads(os.environ["FLOW_LOG_FIELDS"])
INDEX_PREFIX = os.environ["INDEX_PREFIX"]
OPENSEARCH_ENDPOINT = os.environ["OPENSEARCH_ENDPOINT"].rstrip("/")
OPENSEARCH_CREDENTIALS_SECRET_ARN = os.environ["OPENSEARCH_CREDENTIALS_SECRET_ARN"]
PARAMETERS_SECRETS_EXTENSION_HTTP_PORT = os.environ.get("PARAMETERS_SECRETS_EXTENSION_HTTP_PORT", "2773")

NUMERIC_FIELDS = {
    "srcport",
    "dstport",
    "protocol",
    "packets",
    "bytes",
    "start",
    "end",
    "tcp-flags",
    "traffic-path",
}


def handler(event: dict[str, Any], _context: Any) -> dict[str, Any]:
    payload = decode_logs_data(event["awslogs"]["data"])

    if payload.get("messageType") == "CONTROL_MESSAGE":
        logger.info("Received CloudWatch Logs control message")
        return {"status": "ignored", "reason": "control_message"}

    documents = []

    for log_event in payload.get("logEvents", []):
        parsed = parse_flow_log_message(log_event["message"])
        documents.append(build_document(payload, log_event, parsed))

    if not documents:
        logger.info("No flow log documents to index")
        return {"status": "ok", "indexed": 0}

    bulk_body = build_bulk_payload(documents)
    response = send_bulk_request(bulk_body)

    logger.info("Indexed %s flow log documents into OpenSearch", len(documents))
    return {
        "status": "ok",
        "indexed": len(documents),
        "errors": response.get("errors", False),
    }


def decode_logs_data(encoded_payload: str) -> dict[str, Any]:
    compressed_payload = base64.b64decode(encoded_payload)
    uncompressed_payload = gzip.decompress(compressed_payload)
    return json.loads(uncompressed_payload)


def parse_flow_log_message(message: str) -> dict[str, Any]:
    values = message.split()
    document: dict[str, Any] = {"raw_message": message}

    for field_name, value in zip(FLOW_LOG_FIELDS, values):
        normalized_name = field_name.replace("-", "_")
        document[normalized_name] = normalize_value(field_name, value)

    return document


def normalize_value(field_name: str, value: str) -> Any:
    if value == "-":
        return None

    if field_name in NUMERIC_FIELDS:
        try:
            return int(value)
        except ValueError:
            return value

    return value


def build_document(payload: dict[str, Any], log_event: dict[str, Any], parsed: dict[str, Any]) -> dict[str, Any]:
    timestamp_ms = log_event.get("timestamp")
    flow_end = parsed.get("end")

    if isinstance(flow_end, int):
        document_time = dt.datetime.fromtimestamp(flow_end, tz=dt.timezone.utc)
    elif isinstance(timestamp_ms, int):
        document_time = dt.datetime.fromtimestamp(timestamp_ms / 1000, tz=dt.timezone.utc)
    else:
        document_time = dt.datetime.now(tz=dt.timezone.utc)

    document = {
        "@timestamp": document_time.isoformat(),
        "cloudwatch_log_group": payload.get("logGroup"),
        "cloudwatch_log_stream": payload.get("logStream"),
        "cloudwatch_owner": payload.get("owner"),
        "cloudwatch_event_id": log_event.get("id"),
        "cloudwatch_ingestion_time": log_event.get("ingestionTime"),
    }
    document.update(parsed)
    return document


def build_bulk_payload(documents: list[dict[str, Any]]) -> bytes:
    lines: list[str] = []

    for document in documents:
        timestamp = dt.datetime.fromisoformat(document["@timestamp"].replace("Z", "+00:00"))
        index_name = f"{INDEX_PREFIX}-{timestamp:%Y.%m.%d}"
        lines.append(json.dumps({"index": {"_index": index_name}}))
        lines.append(json.dumps(document))

    return ("\n".join(lines) + "\n").encode("utf-8")


def get_opensearch_credentials() -> tuple[str, str]:
    aws_session_token = os.environ["AWS_SESSION_TOKEN"]
    secret_id = parse.quote(OPENSEARCH_CREDENTIALS_SECRET_ARN, safe="")
    secret_url = f"http://localhost:{PARAMETERS_SECRETS_EXTENSION_HTTP_PORT}/secretsmanager/get?secretId={secret_id}"
    secret_request = request.Request(
        url=secret_url,
        headers={"X-Aws-Parameters-Secrets-Token": aws_session_token},
        method="GET",
    )

    try:
        with request.urlopen(secret_request, timeout=5) as response:
            secret_payload = json.loads(response.read().decode("utf-8"))
    except error.HTTPError as exc:
        error_body = exc.read().decode("utf-8", errors="replace")
        logger.error("Secrets extension request failed with status %s: %s", exc.code, error_body)
        raise

    credentials = json.loads(secret_payload["SecretString"])
    return credentials["username"], credentials["password"]


def send_bulk_request(body: bytes) -> dict[str, Any]:
    opensearch_username, opensearch_password = get_opensearch_credentials()
    auth_token = base64.b64encode(f"{opensearch_username}:{opensearch_password}".encode("utf-8")).decode("ascii")
    http_request = request.Request(
        url=f"{OPENSEARCH_ENDPOINT}/_bulk",
        data=body,
        headers={
            "Authorization": f"Basic {auth_token}",
            "Content-Type": "application/x-ndjson",
        },
        method="POST",
    )

    try:
        with request.urlopen(http_request, timeout=30) as response:
            response_payload = json.loads(response.read().decode("utf-8"))
    except error.HTTPError as exc:
        error_body = exc.read().decode("utf-8", errors="replace")
        logger.error("OpenSearch bulk request failed with status %s: %s", exc.code, error_body)
        raise

    if response_payload.get("errors"):
        failed_items = [
            item
            for item in response_payload.get("items", [])
            if item.get("index", {}).get("error")
        ]
        logger.error("OpenSearch bulk request returned item errors: %s", failed_items[:3])
        raise RuntimeError("OpenSearch bulk request returned indexing errors")

    return response_payload
