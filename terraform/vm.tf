resource "google_compute_instance" "bindplane_control" {
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

  metadata_startup_script = templatefile("${path.module}/startup.sh", {
    db_host     = google_sql_database_instance.bindplane_postgres.ip_address[0].ip_address
    db_name     = google_sql_database.bindplane.name
    db_user     = var.db_user
    db_pass     = var.db_password
    admin_user  = var.bindplane_admin_user
    admin_pass  = var.bindplane_admin_password
    license_key = var.bindplane_license
  })
}
