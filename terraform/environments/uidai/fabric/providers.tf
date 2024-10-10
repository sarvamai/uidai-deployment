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
    bucket                      = "test-bucket"
    key                         = "fabric.tfstate"
    region                      = "some-region"                             # Ignore this value
    endpoint                    = "https://0382-45-117-30-6.ngrok-free.app" # Your Ceph S3 endpoint
    access_key                  = "minioadmin"                              # Access key for your Ceph user
    secret_key                  = "minioadmin"                              # Secret key for your Ceph user
    skip_credentials_validation = true                                    
    skip_region_validation      = true                                     
    skip_metadata_api_check     = true                                     
    skip_requesting_account_id  = true                                     
    force_path_style            = true                                     
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "v2v-cluster-h100"
}

provider "helm" {
  kubernetes {
    config_path    = "~/.kube/config"
    config_context = "v2v-cluster-h100"
  }
}
