import io
import logging
import os
from urllib.parse import unquote_plus

import boto3
from PIL import Image, ImageDraw, ImageFont

LOGGER = logging.getLogger()
LOGGER.setLevel(logging.INFO)
s3 = boto3.client("s3")


def _supported_extension(key: str) -> bool:
    return key.lower().endswith((".png", ".jpg", ".jpeg", ".webp"))


def _infer_format(key: str, output_format: str) -> str:
    if output_format and output_format.upper() != "ORIGINAL":
        return output_format.upper()
    key_l = key.lower()
    if key_l.endswith(".png"):
        return "PNG"
    if key_l.endswith(".webp"):
        return "WEBP"
    return "JPEG"


def _destination_key(source_key: str, source_prefix: str, destination_prefix: str) -> str:
    suffix = source_key[len(source_prefix):].lstrip("/")
    return f"{destination_prefix.rstrip('/')}/{suffix}"


def _apply_watermark(image: Image.Image, text: str, opacity: int) -> Image.Image:
    base = image.convert("RGBA")
    overlay = Image.new("RGBA", base.size, (255, 255, 255, 0))
    draw = ImageDraw.Draw(overlay)

    width, height = base.size
    font_size = max(20, min(width, height) // 12)

    try:
        font = ImageFont.truetype("DejaVuSans.ttf", font_size)
    except Exception:
        font = ImageFont.load_default()

    try:
        bbox = draw.textbbox((0, 0), text, font=font, stroke_width=2)
        text_w = bbox[2] - bbox[0]
        text_h = bbox[3] - bbox[1]
    except AttributeError:
        text_w, text_h = draw.textsize(text, font=font)

    x = width - text_w - 24
    y = height - text_h - 24

    draw.rectangle(
        [(x - 14, y - 10), (x + text_w + 14, y + text_h + 10)],
        fill=(0, 0, 0, min(120, opacity)),
    )
    draw.text(
        (x, y),
        text,
        font=font,
        fill=(255, 255, 255, opacity),
        stroke_width=2,
        stroke_fill=(0, 0, 0, min(255, opacity + 40)),
    )

    return Image.alpha_composite(base, overlay)


def lambda_handler(event, context):
    bucket_name = os.environ["BUCKET_NAME"]
    source_prefix = os.environ["SOURCE_PREFIX"].strip("/")
    destination_prefix = os.environ["DESTINATION_PREFIX"].strip("/")
    watermark_text = os.environ.get("WATERMARK_TEXT", "CONFIDENTIAL")
    opacity = int(os.environ.get("WATERMARK_OPACITY", "90"))
    output_format = os.environ.get("OUTPUT_FORMAT", "ORIGINAL")

    for record in event.get("Records", []):
        if not record.get("eventName", "").startswith("ObjectCreated:"):
            continue

        source_key = unquote_plus(record["s3"]["object"]["key"])

        if not source_key.startswith(f"{source_prefix}/"):
            continue

        if source_key.startswith(f"{destination_prefix}/"):
            continue

        if not _supported_extension(source_key):
            LOGGER.info("Skipping unsupported file: %s", source_key)
            continue

        LOGGER.info("Processing object s3://%s/%s", bucket_name, source_key)

        response = s3.get_object(Bucket=bucket_name, Key=source_key)
        payload = response["Body"].read()

        image = Image.open(io.BytesIO(payload))
        watermarked = _apply_watermark(image, watermark_text, opacity)

        dest_key = _destination_key(source_key, source_prefix, destination_prefix)
        selected_format = _infer_format(dest_key, output_format)

        out = io.BytesIO()
        if selected_format == "JPEG":
            watermarked.convert("RGB").save(out, format="JPEG", quality=92, optimize=True)
            content_type = "image/jpeg"
        elif selected_format == "PNG":
            watermarked.save(out, format="PNG", optimize=True)
            content_type = "image/png"
        elif selected_format == "WEBP":
            watermarked.save(out, format="WEBP", quality=90, method=6)
            content_type = "image/webp"
        else:
            raise ValueError(f"Unsupported output format: {selected_format}")

        out.seek(0)

        s3.put_object(
            Bucket=bucket_name,
            Key=dest_key,
            Body=out.getvalue(),
            ContentType=content_type,
            Tagging="generated-by=watermark-lambda",
        )

        LOGGER.info("Saved watermarked file to s3://%s/%s", bucket_name, dest_key)

    return {"statusCode": 200, "message": "Processing complete"}
