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

  backend "local" {
    path = "../../../tfstates/fabric.tfstate"
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
