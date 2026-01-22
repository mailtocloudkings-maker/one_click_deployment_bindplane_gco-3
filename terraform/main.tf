################################
# GLOBAL RANDOM SUFFIX
################################
resource "random_id" "suffix" {
  byte_length = 3
}

################################
# PROJECT SERVICES (OPTIONAL BUT RECOMMENDED)
################################
resource "google_project_service" "required_services" {
  for_each = toset([
    "compute.googleapis.com",
    "sqladmin.googleapis.com",
    "storage.googleapis.com",
    "monitoring.googleapis.com",
    "logging.googleapis.com"
  ])

  service = each.key
  disable_on_destroy = false
}

################################
# BINDPLANE CONTROL VM
################################
# Defined in vm.tf
# Depends on Cloud SQL
################################
resource "google_compute_instance" "bindplane_control" {
  depends_on = [
    google_project_service.required_services,
    google_sql_database_instance.bindplane_postgres
  ]

  name         = "bindplane-control-${random_id.suffix.hex}"
  machine_type = "e2-standard-4"
  zone         = var.zone
  tags         = ["bindplane"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 50
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata_startup_script = file("${path.module}/startup.sh")
}

################################
# BINDPLANE AGENT VM
################################
resource "google_compute_instance" "bindplane_agent" {
  depends_on = [
    google_compute_instance.bindplane_control
  ]

  name         = "bindplane-agent-${random_id.suffix.hex}"
  machine_type = "e2-small"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 30
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata_startup_script = file("${path.module}/bindplane-agent-startup.sh")
}

################################
# NOTE
################################
# - Cloud SQL is created in cloudsql.tf
# - Firewall rules in firewall.tf
# - GCS bucket in gcs.tf
# - GCO objects in gco.tf
# - Alerts in alerts.tf
# - Bindplane pipelines in bindplane_pipeline.tf
# - Outputs in outputs.tf
#
# This file intentionally stays minimal and clean.
################################
