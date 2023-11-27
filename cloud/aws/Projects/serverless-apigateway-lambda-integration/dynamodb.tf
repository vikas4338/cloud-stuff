resource "aws_dynamodb_table" "pets_store" {
  name           = "PetStore"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "PetId"
  range_key      = "Birthdate"

  attribute {
    name = "PetId"
    type = "S"
  }

  attribute {
    name = "Birthdate"
    type = "S"
  }
}