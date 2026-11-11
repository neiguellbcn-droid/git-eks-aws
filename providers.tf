terraform {
  required_version = ">= 1.10.0"

  backend "s3" {
    bucket       = "tfstate-eks-300601069255"
    key          = "eks-prod/terraform.tfstate"
    region       = "eu-west-1"
    encrypt      = true
    use_lockfile = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.30.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.13.0"
    }
  }
}
