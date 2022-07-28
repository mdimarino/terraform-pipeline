output "vpc_id" {
  description = "O ID da VPC"
  value       = aws_vpc.vpc.id
}

output "public_subnets_ids" {
  description = "Os IDs das sub redes públicas"
  value       = aws_subnet.public_subnets[*].id
}

output "private_subnets_ids" {
  description = "Os IDs das sub redes privadas"
  value       = aws_subnet.private_subnets[*].id
}

output "database_subnets_ids" {
  description = "Os IDs das sub redes de base de dados"
  value       = aws_subnet.database_subnets[*].id
}

output "nat_gateways_ips" {
  description = "Os IPs externos dos NAT Gateways"
  value       = aws_nat_gateway.nat_gateways[*].public_ip
}