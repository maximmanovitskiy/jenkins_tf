terraform {
  backend "s3" {
    bucket         = "terraform-20210301092226465500000001"
    key            = "global/s3/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "remote-state-locks"
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
