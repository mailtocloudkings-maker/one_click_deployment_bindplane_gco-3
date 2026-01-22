terraform {
  required_version = ">= 1.4.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5"
    }
  }

  backend "gcs" {
    bucket = "my-terraform-state"   # store your tf state securely
    prefix = "bindplane"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}
