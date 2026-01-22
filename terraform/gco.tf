resource "google_storage_bucket_object" "example" {
  name   = "example-object-${random_id.suffix.hex}"
  bucket = google_storage_bucket.bindplane_bucket.name
  source = "local-file.txt"
}
