resource "google_sql_database_instance" "bindplane" {
  name             = "bindplane-db-${local.name_suffix}"
  database_version = "POSTGRES_15"
  region           = var.region

  settings {
    tier = "db-custom-1-3840"

    ip_configuration {
      ipv4_enabled = true
      authorized_networks {
        value = "0.0.0.0/0"
      }
    }
  }
}

resource "google_sql_database" "bindplane" {
  name     = "bindplane"
  instance = google_sql_database_instance.bindplane.name
}

resource "google_sql_user" "bindplane" {
  name     = var.db_user
  instance = google_sql_database_instance.bindplane.name
  password = var.db_password
}
