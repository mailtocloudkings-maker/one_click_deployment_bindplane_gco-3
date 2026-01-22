resource "google_compute_instance" "bindplane_agent" {
  name         = "bindplane-agent-${local.name_suffix}"
  machine_type = "e2-medium"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata_startup_script = file("${path.module}/bindplane-agent-startup.sh")

  tags = ["bindplane-agent"]
}
