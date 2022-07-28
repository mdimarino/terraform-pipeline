resource "aws_resourcegroups_group" "resource_group" {
  name        = "${var.service}-${var.environment}"
  description = "Grupo de recursos ${var.service}-${var.environment}"

  resource_query {
    query = <<JSON
{
  "ResourceTypeFilters": [
    "AWS::AllSupported"
  ],
  "TagFilters": [
    {
      "Key": "ResourceGroup",
      "Values": ["${var.service}-${var.environment}"]
    }
  ]
}
JSON
  }

  tags = {
    Name = "${var.service}-${var.environment}"
  }
}