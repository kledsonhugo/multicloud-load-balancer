variable "vpc_id" {}
variable "subnet1a_id" {}
variable "subnet1c_id" {}
variable "vpc_cidr_block" {}

variable "elb_name" {
  type    = string
  default = "elbname"

  validation {
    condition = can(regex("^lbaws[a-z]{2}[0-9]{4}$", var.elb_name))

    error_message = <<-EOT
      O nome do balanceador de carga deve seguir o formato: lbawskb0001
      Regras:
        - Deve iniciar com o prefixo fixo 'lbaws'
        - Em seguida, conter duas letras minúsculas (a-z)
        - Finalizar com quatro números (0-9)
      Exemplos válidos:
        - lbawskb0001
        - lbawsdc0123
      Exemplos inválidos:
        - lbawsKB0001  (maiúsculas não permitidas)
        - lbawsab001   (faltando um número)
        - lbawss0001   (faltando uma letra)
    EOT
  }
}
