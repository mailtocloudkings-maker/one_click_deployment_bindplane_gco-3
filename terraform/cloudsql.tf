resource "random_id" "suffix" {
  byte_length = 3
}

resource "google_sql_database_instance" "bindplane_postgres" {
  name             = "bindplane-db-${random_id.suffix.hex}"
  database_version = "POSTGRES_15"
  region           = var.region

  settings {
    tier = "db-f1-micro"
    disk_size = 50

    ip_configuration {
      ipv4_enabled    = true
      authorized_networks {
        value = "0.0.0.0/0"  # restrict later
      }
    }

    backup_configuration {
      enabled = true
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
