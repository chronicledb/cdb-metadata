provider "aws" {
  region = var.region
}

variable "region" {
  description = "AWS region to deploy into"
  type        = string
}

# ---------------------------------------------------------------------------
# users
# pk: id
# GSI: users-by-hashed-api-key (hashedApiKey)
# ---------------------------------------------------------------------------

resource "aws_dynamodb_table" "users" {
  name         = "users"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "hashedApiKey"
    type = "S"
  }

  global_secondary_index {
    name            = "users-by-hashed-api-key"
    hash_key        = "hashedApiKey"
    projection_type = "ALL"
  }

  tags = {
    Name    = "cdb-metadata-users"
    Service = "cdb-metadata"
  }
}

# ---------------------------------------------------------------------------
# chronicles
# pk: userId  sk: name
# (composite key enforces uniqueness per user)
# ---------------------------------------------------------------------------

resource "aws_dynamodb_table" "chronicles" {
  name         = "chronicles"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "userId"
  range_key    = "name"

  attribute {
    name = "userId"
    type = "S"
  }

  attribute {
    name = "name"
    type = "S"
  }

  tags = {
    Name    = "cdb-metadata-chronicles"
    Service = "cdb-metadata"
  }
}

# ---------------------------------------------------------------------------
# replicas
# pk: id
# ---------------------------------------------------------------------------

resource "aws_dynamodb_table" "replicas" {
  name         = "replicas"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "status"
    type = "S"
  }

  global_secondary_index {
    name            = "replicas-by-status"
    hash_key        = "status"
    projection_type = "ALL"
  }

  tags = {
    Name    = "cdb-metadata-replicas"
    Service = "cdb-metadata"
  }
}

# ---------------------------------------------------------------------------
# views
# pk: userId  sk: chronicleName#viewName
# (composite key enforces uniqueness per user + chronicle)
# ---------------------------------------------------------------------------

resource "aws_dynamodb_table" "views" {
  name         = "views"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "userId"
  range_key    = "chronicleNameViewName"

  attribute {
    name = "userId"
    type = "S"
  }

  attribute {
    name = "chronicleNameViewName"
    type = "S"
  }

  tags = {
    Name    = "cdb-metadata-views"
    Service = "cdb-metadata"
  }
}

# ---------------------------------------------------------------------------
# Outputs — useful for other services that depend on cdb-metadata
# ---------------------------------------------------------------------------

output "users_table_name" {
  value = aws_dynamodb_table.users.name
}

output "users_table_arn" {
  value = aws_dynamodb_table.users.arn
}

output "chronicles_table_name" {
  value = aws_dynamodb_table.chronicles.name
}

output "chronicles_table_arn" {
  value = aws_dynamodb_table.chronicles.arn
}

output "replicas_table_name" {
  value = aws_dynamodb_table.replicas.name
}

output "replicas_table_arn" {
  value = aws_dynamodb_table.replicas.arn
}

output "views_table_name" {
  value = aws_dynamodb_table.views.name
}

output "views_table_arn" {
  value = aws_dynamodb_table.views.arn
}
