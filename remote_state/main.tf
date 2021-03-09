provider "aws" {
  region = "us-east-1"
}
resource "aws_s3_bucket" "s3_bucket" {
  acl = "private"
  # policy = file("policy.json")
  versioning {
    enabled = true
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  tags = {
    Name         = "Project_remote_state_s3"
    ResourceName = "S3"
    Owner        = "Maxim Manovitskiy"
  }
}
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "remote-state-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
  tags = {
    Name         = "Project_remote_state_lock"
    ResourceName = "Dynamo_DB"
    Owner        = "Maxim Manovitskiy"
  }
}
