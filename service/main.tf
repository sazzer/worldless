terraform {
  # The provider that we deploy with
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }

  # The backend that we use to store state.
  # Note that this requires that an S3 Bucket and a DynamoDB table with the correct names and structure already exist.
  backend "s3" {
    bucket         = "worldless-terraform"
    key            = "tfstate"
    dynamodb_table = "worldless-terraform"
  }

}

provider "aws" {
  version = "~> 3.7.0"
}

provider "random" {
  version = "~> 2.3.0"
}

provider "template" {
  version = "~> 2.1.2"
}
