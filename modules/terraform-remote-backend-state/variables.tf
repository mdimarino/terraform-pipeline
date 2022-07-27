variable "region" {
  description = "A região que será usada"
  type        = string
}

variable "s3-terraform-remote-state-bucket" {
  description = "O nome do bucket S3 para armazenar o estado das execuções do terraform"
  type        = string
}

variable "s3-versioning-lifecycle-days" {
  description = "Número de dias para manter os arquivos não correntes que estão sendo versionados"
  type        = number
}

variable "dynamodb-lock-table" {
  description = "O nome da tabela no dynamodb para indicar se o estado está travado"
  type        = string
}

variable "resource-group" {
  description = "O nome do bucket S3 para armazenar o estado das execuções do terraform"
  type        = string
}
