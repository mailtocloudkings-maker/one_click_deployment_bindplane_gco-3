resource "google_storage_bucket" "bindplane_bucket" {
  name     = "bindplane-bucket-${random_id.suffix.hex}"
  location = var.region
  force_destroy = true
}
