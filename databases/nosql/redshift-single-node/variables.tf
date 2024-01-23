
variable "region" {
  description = "The AWS region in which to create the VPC"
  default = "us-east-1"
  validation {
    condition     = length(var.region) > 0
    error_message = "Região AWS inválida. A região deve ser uma string não vazia"

  }
}

variable "cluster_identifier" {
  description = "The name of the ElastiCache replication group."
  default     = "redshift-vendasdb-app"
  type        = string
}

variable "final_snapshot_identifier" {
  description = "The identifier of the final snapshot that is to be created immediately before deleting the cluster. If this parameter is provided, `skip_final_snapshot` must be `false`"
  type        = string
  default     = "redshift-vendasdb-app-snapshot"
}

variable "skip_final_snapshot" {
  description = "Determines whether a final snapshot of the cluster is created before Redshift deletes the cluster. If true, a final cluster snapshot is not created. If false , a final cluster snapshot is created before the cluster is deleted"
  type        = bool
  default     = false
}

variable "snapshot_cluster_identifier" {
  description = "The name of the cluster the source snapshot was created from"
  type        = string
  default     = null
}

variable "snapshot_identifier" {
  description = "The name of the snapshot from which to create the new cluster"
  type        = string
  default     = "redshift-vendasdb-app-snapshot"
}

variable "logging" {
  description = "Logging configuration for the cluster"
  type        = any
  default     = {
    enable        = true
    bucket_name   = "my-s3-log-bucket-123123-23-23-23-23"
    s3_key_prefix = "redshift/"
  }
}
variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "preferred_maintenance_window" {
  description = "The weekly time range (in UTC) during which automated cluster maintenance can occur. Format: `ddd:hh24:mi-ddd:hh24:mi`"
  type        = string
  default     = "sat:10:00-sat:10:30"
}


################################################################################
# Parameter Group
################################################################################
variable "parameter_group_name" {
  description = "The name of the Redshift parameter group, existing or to be created"
  type        = string
  default     = "example-custom"
}

variable "parameter_group_description" {
  description = "The description of the Redshift parameter group. Defaults to `Managed by Terraform`"
  type        = string
  default     = "Custom parameter group for example cluster"
}

variable "parameter_group_family" {
  description = "The family of the Redshift parameter group"
  type        = string
  default     = "redshift-1.0"
}

variable "parameter_group_parameters" {
  description = "A map of parameter group settings for Redshift"
  type = map(object({
    name  = string
    value = string
  }))
  default = {
    wlm_json_configuration = {
      name  = "wlm_json_configuration"
      /*value = jsonencode([{
        query_concurrency = 15
      }])*/
      value = "[{\"query_concurrency\": 15}]"
    }
    require_ssl = {
      name  = "require_ssl"
      value = "true"
    }
    use_fips_ssl = {
      name  = "use_fips_ssl"
      value = "false"
    }
    enable_user_activity_logging = {
      name  = "enable_user_activity_logging"
      value = "true"
    }
    max_concurrency_scaling_clusters = {
      name  = "max_concurrency_scaling_clusters"
      value = "3"
    }
    enable_case_sensitive_identifier = {
      name  = "enable_case_sensitive_identifier"
      value = "true"
    }
  }
}

variable "parameter_group_tags" {
  description = "Additional tags to add to the parameter group"
  type        = map(string)
  default     = {}
}

################################################################################
# Usage Limit
################################################################################

variable "usage_limits" {
  description = "Map of usage limit definitions to create"
  type        = any
  default     =  {
    currency_scaling = {
      feature_type  = "concurrency-scaling"
      limit_type    = "time"
      amount        = 60
      breach_action = "emit-metric"
    }
    spectrum = {
      feature_type  = "spectrum"
      limit_type    = "data-scanned"
      amount        = 2
      breach_action = "disable"
      tags = {
        Additional = "CustomUsageLimits"
      }
    }
  }
}

################################################################################
# Endpoint Access
################################################################################
variable "create_endpoint_access" {
  description = "Determines whether to create an endpoint access (managed VPC endpoint)"
  type        = bool
  default     = false
}

variable "endpoint_name" {
  description = "The Redshift-managed VPC endpoint name"
  type        = string
  default     = ""
}
variable "endpoint_resource_owner" {
  description = "The Amazon Web Services account ID of the owner of the cluster. This is only required if the cluster is in another Amazon Web Services account"
  type        = string
  default     = null
}


