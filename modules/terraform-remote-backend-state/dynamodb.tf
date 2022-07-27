resource "aws_dynamodb_table" "dynamodb_table" {
  name           = "${data.aws_caller_identity.current.account_id}-${var.region}-${var.dynamodb-lock-table}"
  hash_key       = "LockID"
  read_capacity  = 1
  write_capacity = 1

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "Terraform remote backend lock table"
  }
}
