terraform {
  backend "gcs" {
    bucket  = "bindplane-tfstate-${var.project_id}"
    prefix  = "state"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    bindplane = {
      source  = "observiq/bindplane"
      version = "~> 1.0"
    }
    random = {
      source = "hashicorp/random"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

provider "bindplane" {
  remote_url = "http://${google_compute_instance.bindplane_control.network_interface[0].access_config[0].nat_ip}:3001"
  api_key    = var.bindplane_api_key
}
