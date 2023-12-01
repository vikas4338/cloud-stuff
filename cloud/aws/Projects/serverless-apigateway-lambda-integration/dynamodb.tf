resource "aws_dynamodb_table" "pets_store" {
  name           = "PetStore"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "Id"
  range_key      = "Breed"

  attribute {
    name = "Id"
    type = "N"
  }

  attribute {
    name = "Breed"
    type = "S"
  }
}