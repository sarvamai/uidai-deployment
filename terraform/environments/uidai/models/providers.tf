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
  }

  backend "s3" {
    bucket                      = "test-bucket"
    key                         = "models.tfstate"
    region                      = "some-region"                    # Update with the region
    endpoint                    = "https://0382-45-117-30-6.ngrok-free.app" # Your Ceph S3 endpoint
    access_key                  = "minioadmin"
    secret_key                  = "minioadmin"
    skip_credentials_validation = true                                     # Skip AWS credential validation
    skip_region_validation      = true                                     # Skip AWS region validation
    skip_metadata_api_check     = true                                     # Skip calls to AWS metadata API
    skip_requesting_account_id  = true                                     # Skip retrieving AWS account details
    force_path_style            = true                                     # Use path-style for Ceph/MinIO

  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "v2v-cluster-h100"
}
