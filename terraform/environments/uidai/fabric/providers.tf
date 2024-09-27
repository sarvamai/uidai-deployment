terraform {
  required_version = ">= 1.0"

  required_providers {

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.3"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "= 2.14.0"
    }
  }

  backend "s3" {
    bucket                      = "my-ceph-bucket"
    key                         = "fabric.tfstate"
    region                      = "us-east-1"                    # Update with the region
    endpoint                    = "http://ceph-cluster-url:port" # Your Ceph S3 endpoint
    access_key                  = "your-ceph-access-key"
    secret_key                  = "your-ceph-secret-key"
    skip_credentials_validation = true # Required for Ceph
    skip_region_validation      = true # Required for Ceph
  }
}

provider "kubernetes" {
  config_path    = ""
  config_context = ""
}

provider "helm" {
  kubernetes {
    config_path    = ""
    config_context = ""
  }
}
