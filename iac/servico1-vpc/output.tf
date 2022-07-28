output "vpc_id" {
  description = "O ID da VPC"
  value       = module.network.vpc_id
}

output "public_subnets_ids" {
  description = "Os IDs das sub redes públicas"
  value       = module.network.public_subnets_ids
}

output "private_subnets_ids" {
  description = "Os IDs das sub redes privadas"
  value       = module.network.private_subnets_ids
}

output "database_subnets_ids" {
  description = "Os IDs das sub redes de base de dados"
  value       = module.network.database_subnets_ids
}

output "ips_externos" {
  description = "Os IPs externos usados nos NAT Gateways"
  value       = module.network.nat_gateways_ips
}
