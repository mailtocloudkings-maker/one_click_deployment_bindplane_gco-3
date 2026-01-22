########################################
# Cloud SQL Postgres for Bindplane
########################################

resource "google_sql_database_instance" "bindplane_postgres" {
  name             = "bindplane-db"
  database_version = "POSTGRES_15"
  region           = var.region

  settings {
    tier = "db-f1-micro" # adjust based on load

    ip_configuration {
      ipv4_enabled = true
      authorized_networks {
        value = "0.0.0.0/0"  # WARNING: allow all, restrict later
      }
    }
  }
}

# Create the database
resource "google_sql_database" "bindplane" {
  name     = "bindplane"
  instance = google_sql_database_instance.bindplane_postgres.name
}

# Create the user
resource "google_sql_user" "bindplane_user" {
  name     = var.db_user
  instance = google_sql_database_instance.bindplane_postgres.name
  password = var.db_password
}

# Set schema privileges (Terraform provider doesn't support ALTER SCHEMA directly)
resource "null_resource" "bindplane_schema_grants" {
  depends_on = [
    google_sql_user.bindplane_user,
    google_sql_database.bindplane
  ]

  provisioner "local-exec" {
    command = <<EOT
PGPASSWORD=${var.db_password} psql \
-h ${google_sql_database_instance.bindplane_postgres.public_ip_address} \
-U ${var.db_user} \
-d ${google_sql_database.bindplane.name} \
-c "GRANT USAGE, CREATE ON SCHEMA public TO ${var.db_user};" \
-c "ALTER SCHEMA public OWNER TO ${var.db_user};"
EOT
  }
}
