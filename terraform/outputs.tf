################################
# Bindplane UI URL
################################
output "bindplane_ui_url" {
  description = "Bindplane UI URL"
  value       = "http://${google_compute_instance.bindplane_control.network_interface[0].access_config[0].nat_ip}:3001"
}

################################
# Bindplane VM Public IP
################################
output "bindplane_vm_ip" {
  description = "Public IP of Bindplane control VM"
  value       = google_compute_instance.bindplane_control.network_interface[0].access_config[0].nat_ip
}

################################
# Cloud SQL Instance Name
################################
output "cloudsql_instance_name" {
  description = "Cloud SQL Postgres instance name"
  value       = google_sql_database_instance.bindplane_postgres.name
}

################################
# Cloud SQL Database Name
################################
output "cloudsql_database" {
  description = "Bindplane database name"
  value       = google_sql_database.bindplane.name
}

################################
# GCS Bucket for Logs
################################
output "gcs_bucket_name" {
  description = "GCS bucket receiving Bindplane logs"
  value       = google_storage_bucket.bindplane_bucket.name
}

################################
# Bindplane Pipeline Names
################################
output "bindplane_logs_pipeline" {
  description = "Bindplane logs configuration name"
  value       = bindplane_configuration.logs_config.name
}

output "bindplane_metrics_pipeline" {
  description = "Bindplane metrics configuration name"
  value       = bindplane_configuration.metrics_config.name
}
