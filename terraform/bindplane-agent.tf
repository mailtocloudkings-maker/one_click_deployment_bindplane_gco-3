resource "google_compute_instance" "bindplane_agent" {
  name         = "bindplane-agent-${random_id.suffix.hex}"
  machine_type = "e2-small"
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

  metadata_startup_script = file("bindplane-agent-startup.sh")
}
