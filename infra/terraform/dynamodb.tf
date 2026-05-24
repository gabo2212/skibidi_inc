resource "aws_dynamodb_table" "users" {
  name         = "${local.name_prefix}-users"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "userId"

  attribute {
    name = "userId"
    type = "S"
  }

  attribute {
    name = "cognitoSub"
    type = "S"
  }

  attribute {
    name = "instructorId"
    type = "S"
  }

  global_secondary_index {
    name            = "cognitoSub-index"
    hash_key        = "cognitoSub"
    projection_type = "ALL"
  }

  global_secondary_index {
    name            = "instructorId-index"
    hash_key        = "instructorId"
    projection_type = "ALL"
  }
}

resource "aws_dynamodb_table" "tasks" {
  name         = "${local.name_prefix}-tasks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "taskId"

  attribute {
    name = "taskId"
    type = "S"
  }

  attribute {
    name = "assignedTo"
    type = "S"
  }

  attribute {
    name = "createdBy"
    type = "S"
  }

  global_secondary_index {
    name            = "assignedTo-index"
    hash_key        = "assignedTo"
    projection_type = "ALL"
  }

  global_secondary_index {
    name            = "createdBy-index"
    hash_key        = "createdBy"
    projection_type = "ALL"
  }
}

resource "aws_dynamodb_table" "notifications" {
  name         = "${local.name_prefix}-notifications"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "userId"
  range_key    = "notificationId"

  attribute {
    name = "userId"
    type = "S"
  }

  attribute {
    name = "notificationId"
    type = "S"
  }
}
