resource "aws_resourcegroups_group" "resource_group" {
  name        = var.resource-group
  description = "Terraform Remote Backend State"

  resource_query {
    query = <<JSON
{
  "ResourceTypeFilters": [
    "AWS::AllSupported"
  ],
  "TagFilters": [
    {
      "Key": "ResourceGroup",
      "Values": ["${var.resource-group}"]
    }
  ]
}
JSON
  }

  tags = {
    Name = var.resource-group
  }
}