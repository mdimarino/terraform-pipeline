output "vpc_id" {
  description = "O ID da VPC"
  value       = module.vpc.vpc_id
}

output "public_subnets_ids" {
  description = "Os IDs das sub redes públicas"
  value       = module.vpc.public_subnets_ids
}

output "private_subnets_ids" {
  description = "Os IDs das sub redes privadas"
  value       = module.vpc.private_subnets_ids
}

output "database_subnets_ids" {
  description = "Os IDs das sub redes de base de dados"
  value       = module.vpc.database_subnets_ids
}

output "ips_externos" {
  description = "Os IPs externos usados nos NAT Gateways"
  value       = module.vpc.nat_gateways_ips
}
