variable "service" {
  description = "Nome do serviço"
  type        = string
}

variable "environment" {
  description = "Nome do ambiente"
  type        = string
}

variable "kubernetes_version" {
  description = "A Versão do Kubernetes que será usada no cluster"
  type        = string
}

variable "endpoint_private_access" {
  description = "Permite acesso interno ao cluster"
  type        = bool
}

variable "endpoint_public_access" {
  description = "Permite acesso exerno ao cluster"
  type        = bool
}

variable "public_access_cidrs" {
  description = "Intervalos de IPs públicos terão acesso permitido ao cluster"
  type        = list(string)
}

variable "enabled_cluster_log_types" {
  description = "Habilita tipos de logs do cluster"
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "vpc_id" {
  description = "O ID da vpc"
  type        = string
}

variable "service_ipv4_cidr" {
  description = "O CIDR da rede interna do Kubernetes"
  type        = string
}

variable "public_subnets_ids" {
  description = "Os IDs das nas subnets públicas"
  type        = list(string)
}

variable "private_subnets_ids" {
  description = "Os IDs das subnets privadas"
  type        = list(string)
}

variable "fargate_profile_namespaces" {
  description = "O nome dos profiles fargate para os namespaces"
  type        = list(string)
}

variable "eks_node_groups" {
  description = "O nome dos node groups no EKS"
  type        = list(string)
}
