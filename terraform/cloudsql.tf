resource "google_sql_database_instance" "bindplane_postgres" {
  name             = "bindplane-db"
  database_version = "POSTGRES_15"
  region           = var.region

  settings {
    tier = "db-f1-micro"

    ip_configuration {
      ipv4_enabled    = true
      authorized_networks {
        value = "0.0.0.0/0"  # restrict later
      }
    }
  }
}

resource "google_sql_database" "bindplane" {
  name     = "bindplane"
  instance = google_sql_database_instance.bindplane_postgres.name
}

resource "google_sql_user" "bindplane_user" {
  name     = var.db_user
  instance = google_sql_database_instance.bindplane_postgres.name
  password = var.db_password
}
