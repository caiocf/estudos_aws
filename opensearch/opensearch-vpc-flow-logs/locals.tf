locals {
  opensearch_https_endpoint = format("https://%s", try(aws_opensearch_domain.this.endpoint_v2, aws_opensearch_domain.this.endpoint))

  # Official AWS docs for the latest layer versions:
  # https://docs.aws.amazon.com/systems-manager/latest/userguide/ps-integration-lambda-extensions.html
  # This map uses the x86_64 layer ARNs because the Lambda in this project is configured with architectures = ["x86_64"].
  parameters_secrets_extension_layer_arns_by_region = {
    af-south-1     = "arn:aws:lambda:af-south-1:317013901791:layer:AWS-Parameters-and-Secrets-Lambda-Extension:60"
    ap-east-1      = "arn:aws:lambda:ap-east-1:768336418462:layer:AWS-Parameters-and-Secrets-Lambda-Extension:60"
    ap-east-2      = "arn:aws:lambda:ap-east-2:890742577149:layer:AWS-Parameters-and-Secrets-Lambda-Extension:33"
    ap-northeast-1 = "arn:aws:lambda:ap-northeast-1:133490724326:layer:AWS-Parameters-and-Secrets-Lambda-Extension:60"
    ap-northeast-2 = "arn:aws:lambda:ap-northeast-2:738900069198:layer:AWS-Parameters-and-Secrets-Lambda-Extension:59"
    ap-northeast-3 = "arn:aws:lambda:ap-northeast-3:576959938190:layer:AWS-Parameters-and-Secrets-Lambda-Extension:58"
    ap-south-1     = "arn:aws:lambda:ap-south-1:176022468876:layer:AWS-Parameters-and-Secrets-Lambda-Extension:58"
    ap-south-2     = "arn:aws:lambda:ap-south-2:070087711984:layer:AWS-Parameters-and-Secrets-Lambda-Extension:55"
    ap-southeast-1 = "arn:aws:lambda:ap-southeast-1:044395824272:layer:AWS-Parameters-and-Secrets-Lambda-Extension:61"
    ap-southeast-2 = "arn:aws:lambda:ap-southeast-2:665172237481:layer:AWS-Parameters-and-Secrets-Lambda-Extension:63"
    ap-southeast-3 = "arn:aws:lambda:ap-southeast-3:490737872127:layer:AWS-Parameters-and-Secrets-Lambda-Extension:58"
    ap-southeast-4 = "arn:aws:lambda:ap-southeast-4:090732460067:layer:AWS-Parameters-and-Secrets-Lambda-Extension:48"
    ap-southeast-5 = "arn:aws:lambda:ap-southeast-5:381492012281:layer:AWS-Parameters-and-Secrets-Lambda-Extension:47"
    ap-southeast-6 = "arn:aws:lambda:ap-southeast-6:995508174458:layer:AWS-Parameters-and-Secrets-Lambda-Extension:42"
    ap-southeast-7 = "arn:aws:lambda:ap-southeast-7:941377119484:layer:AWS-Parameters-and-Secrets-Lambda-Extension:48"
    ca-central-1   = "arn:aws:lambda:ca-central-1:200266452380:layer:AWS-Parameters-and-Secrets-Lambda-Extension:65"
    ca-west-1      = "arn:aws:lambda:ca-west-1:243964427225:layer:AWS-Parameters-and-Secrets-Lambda-Extension:35"
    cn-north-1     = "arn:aws-cn:lambda:cn-north-1:287114880934:layer:AWS-Parameters-and-Secrets-Lambda-Extension:64"
    cn-northwest-1 = "arn:aws-cn:lambda:cn-northwest-1:287310001119:layer:AWS-Parameters-and-Secrets-Lambda-Extension:61"
    eu-central-1   = "arn:aws:lambda:eu-central-1:187925254637:layer:AWS-Parameters-and-Secrets-Lambda-Extension:61"
    eu-central-2   = "arn:aws:lambda:eu-central-2:772501565639:layer:AWS-Parameters-and-Secrets-Lambda-Extension:42"
    eu-north-1     = "arn:aws:lambda:eu-north-1:427196147048:layer:AWS-Parameters-and-Secrets-Lambda-Extension:58"
    eu-south-1     = "arn:aws:lambda:eu-south-1:325218067255:layer:AWS-Parameters-and-Secrets-Lambda-Extension:58"
    eu-south-2     = "arn:aws:lambda:eu-south-2:524103009944:layer:AWS-Parameters-and-Secrets-Lambda-Extension:54"
    eu-west-1      = "arn:aws:lambda:eu-west-1:015030872274:layer:AWS-Parameters-and-Secrets-Lambda-Extension:63"
    eu-west-2      = "arn:aws:lambda:eu-west-2:133256977650:layer:AWS-Parameters-and-Secrets-Lambda-Extension:59"
    eu-west-3      = "arn:aws:lambda:eu-west-3:780235371811:layer:AWS-Parameters-and-Secrets-Lambda-Extension:58"
    eusc-de-east-1 = "arn:aws-eusc:lambda:eusc-de-east-1:041683371183:layer:AWS-Parameters-and-Secrets-Lambda-Extension:5"
    il-central-1   = "arn:aws:lambda:il-central-1:148806536434:layer:AWS-Parameters-and-Secrets-Lambda-Extension:35"
    me-central-1   = "arn:aws:lambda:me-central-1:858974508948:layer:AWS-Parameters-and-Secrets-Lambda-Extension:58"
    me-south-1     = "arn:aws:lambda:me-south-1:832021897121:layer:AWS-Parameters-and-Secrets-Lambda-Extension:58"
    mx-central-1   = "arn:aws:lambda:mx-central-1:241533131596:layer:AWS-Parameters-and-Secrets-Lambda-Extension:32"
    sa-east-1      = "arn:aws:lambda:sa-east-1:933737806257:layer:AWS-Parameters-and-Secrets-Lambda-Extension:61"
    us-east-1      = "arn:aws:lambda:us-east-1:177933569100:layer:AWS-Parameters-and-Secrets-Lambda-Extension:61"
    us-east-2      = "arn:aws:lambda:us-east-2:590474943231:layer:AWS-Parameters-and-Secrets-Lambda-Extension:67"
    us-gov-east-1  = "arn:aws-us-gov:lambda:us-gov-east-1:129776340158:layer:AWS-Parameters-and-Secrets-Lambda-Extension:58"
    us-gov-west-1  = "arn:aws-us-gov:lambda:us-gov-west-1:127562683043:layer:AWS-Parameters-and-Secrets-Lambda-Extension:58"
    us-west-1      = "arn:aws:lambda:us-west-1:997803712105:layer:AWS-Parameters-and-Secrets-Lambda-Extension:59"
    us-west-2      = "arn:aws:lambda:us-west-2:345057560386:layer:AWS-Parameters-and-Secrets-Lambda-Extension:61"
  }

  parameters_secrets_extension_layer_arn = var.parameters_secrets_extension_layer_arn != null ? var.parameters_secrets_extension_layer_arn : lookup(local.parameters_secrets_extension_layer_arns_by_region, data.aws_region.current.region, null)

  flow_log_fields = [
    "version",
    "account-id",
    "interface-id",
    "srcaddr",
    "dstaddr",
    "srcport",
    "dstport",
    "protocol",
    "packets",
    "bytes",
    "start",
    "end",
    "action",
    "log-status",
    "vpc-id",
    "subnet-id",
    "instance-id",
    "tcp-flags",
    "type",
    "pkt-srcaddr",
    "pkt-dstaddr",
    "region",
    "az-id",
    "sublocation-type",
    "sublocation-id",
    "flow-direction",
    "traffic-path",
  ]

  flow_log_format = join(" ", [for field in local.flow_log_fields : format("$${%s}", field)])

  flow_logs_log_group_name           = format("/aws/vpc/flow-logs/%s", var.domain_name)
  flow_logs_lambda_log_group_name    = format("/aws/lambda/%s-flow-logs-to-opensearch", var.domain_name)
  flow_logs_lambda_function_name     = format("%s-flow-logs-to-opensearch", var.domain_name)
  flow_logs_opensearch_secret_name   = format("%s-opensearch-admin-credentials", var.domain_name)
  flow_logs_subscription_filter_name = format("%s-vpc-flow-logs-to-opensearch", var.domain_name)
  flow_logs_lambda_zip_path          = "${path.module}/artifacts/flow-logs-to-opensearch.zip"
  flow_logs_index_pattern            = format("%s-*", var.flow_logs_index_prefix)
  flow_logs_lambda_source_code_hash  = filebase64sha256(local.flow_logs_lambda_zip_path)
  vpc_flow_logs_source_log_group_arn = "arn:${data.aws_partition.current.partition}:logs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:log-group:${local.flow_logs_log_group_name}:*"
}
