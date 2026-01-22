# ------------------------
# GCP Configuration
# ------------------------
project_id = "my-gcp-project"
region     = "us-central1"
zone       = "us-central1-a"

# ------------------------
# Alerting
# ------------------------
alert_email = "alerts@mydomain.com"

# ------------------------
# BindPlane API (generated later by GitHub Actions)
# ------------------------
bindplane_api_key = "YOUR_BINDPLANE_API_KEY"

# ------------------------
# Cloud SQL (PostgreSQL)
# ------------------------
db_user     = "bindplane"
db_password = "StrongPassword@2026"

# ------------------------
# BindPlane Server
# ------------------------
bindplane_admin_password = "StrongPassword@2026"

# License key (base64, multi-line allowed)
bindplane_license = <<EOF
YOUR_LICENSE_KEY
EOF
