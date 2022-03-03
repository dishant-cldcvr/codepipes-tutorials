terraform {
  required_version = ">= 0.13.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.74"
    }
    helm = {
      source = "hashicorp/helm"
      version = "2.1.2"
    }
  }
}