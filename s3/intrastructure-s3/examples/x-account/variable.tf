variable "env" {
  description = "(Optional) Definição de criação para cada ambiente (dev/hom/prod)"
  type = string
  default = null
}


variable "cross_account_policy" {
  description = "(Required) Variavel para configurar acesso Cross Account ao Bucket Full ou Read ou Write"
  type = list(object({
    access_mode = string
    access_roles = list(string)
    organization_paths = list(string)

  }))
/*  default = [
    {
      access_mode = "Full"
      access_roles = ["arn:aws:iam::account_id:role/RoleName1", "arn:aws:iam::account_id:role/RoleName2"]
      organization_paths = ["ou=Finance,ou=Departments,dc=example,dc=com", "ou=HR,ou=Departments,dc=example,dc=com"]
    }
  ]*/

  validation {
    condition = alltrue( [ for p in var.cross_account_policy : contains(["Full","Read", "Write"], p.access_mode)  ] )
    error_message = "Erro ao configurar 'access_mode'"
  }
}

