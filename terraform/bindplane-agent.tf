resource "google_compute_instance" "bindplane_agent" {
  name         = "bindplane-agent"
  machine_type = "e2-medium"
  zone         = var.zone
  tags         = ["bindplane-agent"]

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

  metadata_startup_script = templatefile("${path.module}/bindplane-agent-startup.sh", {
    control_plane_url = var.bindplane_control_plane_url
    agent_token       = var.bindplane_agent_token
  })
}
