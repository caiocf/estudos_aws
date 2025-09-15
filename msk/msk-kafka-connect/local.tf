locals {
  #rds_master_secret_arn  = aws_rds_cluster.this.master_user_secret[0].secret_arn
  #rds_master_secret_name = trimprefix(element(split(":", local.rds_master_secret_arn), 6), "secret:")

  cluster_arn      = aws_msk_cluster.cluster.arn
  topic_prefix_arn = replace(local.cluster_arn, ":cluster/", ":topic/")
  group_prefix_arn = replace(local.cluster_arn, ":cluster/", ":group/")
}