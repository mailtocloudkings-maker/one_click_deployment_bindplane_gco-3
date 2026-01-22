variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
}

variable "zone" {
  description = "GCP zone for VM"
  type        = string
  default     = "us-central1-a"
}

variable "alert_email" {
  description = "Email for alert notifications"
  type        = string
}

variable "bindplane_api_key" {
  description = "BindPlane API key"
  type        = string
  sensitive   = true
}

variable "db_user" {
  description = "Bindplane Postgres user"
  type        = string
}

variable "db_password" {
  description = "Bindplane Postgres password"
  type        = string
  sensitive   = true
}

variable "bindplane_admin_user" {
  description = "Bindplane admin username"
  type        = string
}

variable "bindplane_admin_password" {
  description = "Bindplane admin password"
  type        = string
  sensitive   = true
}

variable "bindplane_license" {
  description = "Bindplane license key"
  type        = string
  sensitive   = true
}
