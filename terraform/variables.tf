variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "zone" {
  type    = string
  default = "us-central1-a"
}

variable "alert_email" {
  type = string
}

variable "bindplane_api_key" {
  type      = string
  sensitive = true
}

variable "db_user" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "bindplane_admin_password" {
  type      = string
  sensitive = true
}

variable "bindplane_license" {
  type      = string
  sensitive = true
}
