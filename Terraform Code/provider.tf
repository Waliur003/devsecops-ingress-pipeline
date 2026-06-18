//Declare Terraform block and specify the required version of Terraform
terraform {
  required_version = ">= 0.12"

    required_providers {
        aws = {
        source  = "hashicorp/aws"
        version = "~> 5.0"
        }
    }
}



//Configure the AWS provider and specify the region
provider "aws" {
  region = var.aws_region
}