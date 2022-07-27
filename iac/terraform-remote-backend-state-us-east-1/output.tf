output "aws_s3_bucket_remote_state" {
  description = "Nome do bucket S3 que armazena o estado remoto"
  value       = module.terraform-remote-state.aws_s3_bucket_remote_state
}

output "aws_dynamodb_table_remote_state" {
  description = "Nome da tabela DynamoDB que possui os locks de execução"
  value       = module.terraform-remote-state.aws_dynamodb_table_remote_state
}
