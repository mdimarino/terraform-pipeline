resource "aws_cloudwatch_log_group" "eks_log_group" {
  name = "/aws/eks/${var.service}-${var.environment}/cluster"

  retention_in_days = 30

  tags = {
    Name = "/aws/eks/${var.service}-${var.environment}/cluster"
  }
}

resource "aws_cloudwatch_log_group" "applications_log_group" {
  name = "/dock/applications/${var.service}-${var.environment}"

  retention_in_days = 30

  tags = {
    Name = "/dock/applications/${var.service}-${var.environment}"
  }
}

resource "aws_cloudwatch_log_group" "applications_stdout_log_group" {
  name = "/dock/applications/${var.service}-${var.environment}/stdout"

  retention_in_days = 30

  tags = {
    Name = "/dock/applications/${var.service}-${var.environment}/stdout"
  }
}
