output "aws_s3_bucket_remote_state" {
  description = "Nome do bucket S3 que armazena o estado remoto"
  value       = aws_s3_bucket.s3_bucket.id
}

output "aws_dynamodb_table_remote_state" {
  description = "Nome da tabela DynamoDB que possui os locks de execução"
  value       = aws_dynamodb_table.dynamodb_table.name
}
