locals {
    bucket_policies = {
      storage_gateway = {
        create = true
        json = data.aws_iam_policy_document.storage_gateway_policy.json
      }
      custom = {
        create = var.bucket_policy != null
        json = var.bucket_policy
      }
    }
}