terraform {
  backend "s3" {
    bucket         = "terraform-20210301092226465500000001"
    key            = "QA/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "qa_lock"
    encrypt        = true
  }
}
provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {
  state = "available"
}

# ______________________________________________________________________________
