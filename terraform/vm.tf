resource "google_compute_instance" "bindplane_control" {
  name         = "bindplane-control-${local.name_suffix}"
  machine_type = "e2-standard-4"
  zone         = var.zone

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

  metadata_startup_script = templatefile("${path.module}/startup.sh", {
    DB_HOST     = google_sql_database_instance.bindplane.public_ip_address
    DB_USER     = var.db_user
    DB_PASSWORD = var.db_password
    LICENSE     = var.bindplane_license
    ADMIN_PASS  = var.bindplane_admin_password
  })

  tags = ["bindplane"]
}
