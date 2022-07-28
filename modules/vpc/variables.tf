variable "service" {
  description = "Nome do serviço"
  type        = string
}

variable "environment" {
  description = "Nome do ambiente da aplicação"
  type        = string
}

variable "vpc-cidr-block" {
  description = "O CIDR da vpc"
  type        = string
}

variable "public-subnet-cidr-blocks" {
  description = "Os intervalos de IPs usados nas subnets públicas"
  type        = list(string)
}

variable "private-subnet-cidr-blocks" {
  description = "Os intervalos de IPs usados nas subnets privadas"
  type        = list(string)
}

variable "database-subnet-cidr-blocks" {
  description = "Os intervalos de IPs usados nas subnets para base de dados"
  type        = list(string)
  default     = [null]
}

variable "availability-zones" {
  description = "As zonas de disponibilidade da região"
  type        = list(string)
}

variable "create-nat-gateways" {
  description = "Se verdadeiro NAT Gateways serão criados nas subredes públicas e rotas de saída para as subredes privadas"
  type        = bool
  default     = true
}

variable "create-database-subnets" {
  description = "Se verdadeiro subredes para base de dados serão criadas e rotas de saída pelos NAT Gateways"
  type        = bool
  default     = false
}
