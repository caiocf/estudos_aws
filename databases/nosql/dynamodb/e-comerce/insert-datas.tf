
resource "aws_dynamodb_table_item" "item1" {
  table_name = aws_dynamodb_table.users.name
  hash_key   = "UserID"
  range_key  = "OrderID"

  item = <<ITEM
{
  "UserID": {"N": "1"},
  "OrderID": {"N": "101"},
  "Email": {"S": "user1@example.com"},
  "FullName": {"S": "User 1"},
  "address": {"S": "{\"home\": \"123 Main St\", \"city\": \"Anytown\"}"},
  "LastLoginDate": {"S": "2023-01-01"}
}
ITEM
}

resource "aws_dynamodb_table_item" "item11" {
  table_name = aws_dynamodb_table.users.name
  hash_key   = "UserID"
  range_key  = "OrderID"

  item = <<ITEM
{
  "UserID": {"N": "1"},
  "OrderID": {"N": "2011"},
  "Email": {"S": "user1@example.com"},
  "FullName": {"S": "User 1"},
  "address": {"S": "{\"home\": \"123 Main St\", \"city\": \"Anytown\"}"},
  "LastLoginDate": {"S": "2023-01-02"}
}
ITEM
}

resource "aws_dynamodb_table_item" "item2" {
  table_name = aws_dynamodb_table.users.name
  hash_key   = "UserID"
  range_key  = "OrderID"

  item = <<ITEM
{
  "UserID": {"N": "2"},
  "OrderID": {"N": "102"},
  "Email": {"S": "user2@example.com"},
  "FullName": {"S": "User 2"},
  "address": {"S": "{\"home\": \"102 Main St\", \"city\": \"Anytown\"}"},
  "LastLoginDate": {"S": "2023-01-02"}
}
ITEM
}

resource "aws_dynamodb_table_item" "item3" {
  table_name = aws_dynamodb_table.users.name
  hash_key   = "UserID"
  range_key  = "OrderID"

  item = <<ITEM
{
  "UserID": {"N": "3"},
  "OrderID": {"N": "103"},
  "Email": {"S": "user3@example.com"},
  "FullName": {"S": "User 3"},
  "address": {"S": "{\"home\": \"1021 Main St\", \"city\": \"Anytown\"}"},
  "LastLoginDate": {"S": "2023-01-03"}
}
ITEM
}

resource "aws_dynamodb_table_item" "item4" {
  table_name = aws_dynamodb_table.users.name
  hash_key   = "UserID"
  range_key  = "OrderID"

  item = <<ITEM
{
  "UserID": {"N": "4"},
  "OrderID": {"N": "104"},
  "Email": {"S": "user4@example.com"},
  "FullName": {"S": "User 4"},
  "address": {"S": "{\"home\": \"311 Main St\", \"city\": \"Anytown\"}"},
  "LastLoginDate": {"S": "2023-01-03"},
  "data_expiracao_registro": {"N": "1703354880"}
}
ITEM
}