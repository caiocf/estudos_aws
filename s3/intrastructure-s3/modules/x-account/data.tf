data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "policy" {
  source_policy_documents = [for policy in local.bucket_policies : policy.json if policy.create]
}

data "aws_iam_policy_document" "cross_account_policy" {
  for_each = {
    for index, policy in var.cross_account_policy : "AllowAccessCrossAccount:${index}=${policy.access_mode}" => {
      actions = local.bucket_allowed_actions[policy.access_mode]
      policy = policy
    }
  }

  statement {
    sid = each.key
    principals {
      identifiers = each.value.policy.access_roles
      type        = "AWS"
    }
    effect = "Allow"
    actions = each.value.actions
    resources = [
      "${module.bucket_s3_x_account.s3_bucket_arn}/*",
      module.bucket_s3_x_account.s3_bucket_arn
    ]
    condition {
      test     = "ForAnyValue:StringLike"
      variable = "aws:PrincipalOrgPaths"
      values   = each.value.policy.organization_paths
    }
  }
}

data "aws_iam_policy_document" "kms_key_policy"{
  count = local.create_kms_key ? 1 : 0
  statement {
    sid = "Allow administration of the key"
    effect = "Allow"
    principals {
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      ]
      type        = "AWS"
    }
    actions = [
      "kms:*"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:CalledAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }

  statement {
    sid = "Allow use of the key"
    effect = "Allow"
    principals {
      identifiers = distinct(flatten([ for policy in var.cross_account_policy : policy.access_roles ]))
      type        = "AWS"
    }
    actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
    ]
  }

}