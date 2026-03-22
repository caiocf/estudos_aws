data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}
data "aws_region" "current" {}
data "aws_vpc" "default" {
  default = true
}

data "aws_iam_policy_document" "opensearch_access" {
  statement {
    sid    = "AllowRequestsHandledByFineGrainedAccessControl"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = ["es:ESHttp*"]

    resources = [
      "arn:${data.aws_partition.current.partition}:es:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:domain/${var.domain_name}/*"
    ]
  }
}
