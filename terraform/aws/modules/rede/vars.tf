variable "vpc_cidr_block" {
  type    = string
  default = "10.0.0.0/16"

  validation {
    condition = (
      # Regex garante formato básico IPv4/CIDR
      can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]{1,2}$", var.vpc_cidr_block)) &&
      # Função nativa valida se o CIDR é realmente válido (ex: 300.0.0.0/24 seria rejeitado)
      can(cidrhost(var.vpc_cidr_block, 0))
    )

    error_message = <<-EOT
      O bloco de rede deve estar em formato CIDR válido, por exemplo:
        - 10.0.0.0/16
        - 192.168.1.0/24
      Regras:
        - Deve conter quatro octetos (0–255)
        - Deve incluir uma máscara de rede (/0 a /32)
        - Exemplo inválido: "10.0.0.0" (sem /24) ou "300.1.1.0/24"
    EOT
  }
}
