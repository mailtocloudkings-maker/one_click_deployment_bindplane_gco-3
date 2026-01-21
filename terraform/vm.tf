resource "google_compute_instance" "bindplane_control" {
  name         = "bindplane-control-${random_id.suffix.hex}"
  machine_type = "e2-standard-4"
  zone         = var.zone
  tags         = ["bindplane"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 50
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata_startup_script = <<-SCRIPT
#!/bin/bash
set -e
LOG=/var/log/bindplane-startup.log
exec > >(tee -a $LOG) 2>&1

echo "=== STARTUP SCRIPT BEGIN ==="

############################
# OS PACKAGES
############################
apt-get update -y
apt-get install -y curl postgresql postgresql-contrib

systemctl enable postgresql
systemctl start postgresql

############################
# POSTGRES SETUP
############################
sudo -u postgres psql -tc "SELECT 1 FROM pg_database WHERE datname = 'bindplane'" | grep -q 1 || \
sudo -u postgres psql -c "CREATE DATABASE bindplane;"

sudo -u postgres psql -tc "SELECT 1 FROM pg_roles WHERE rolname = 'bindplane'" | grep -q 1 || \
sudo -u postgres psql -c "CREATE USER bindplane WITH PASSWORD 'StrongPassword@2025';"

sudo -u postgres psql -c "ALTER DATABASE bindplane OWNER TO bindplane;"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE bindplane TO bindplane;"
sudo -u postgres psql -d bindplane -c "GRANT USAGE, CREATE ON SCHEMA public TO bindplane;"
sudo -u postgres psql -d bindplane -c "ALTER SCHEMA public OWNER TO bindplane;"

############################
# INSTALL BINDPLANE
############################
curl -fsSL https://storage.googleapis.com/bindplane-op-releases/bindplane/latest/install-linux.sh -o /tmp/install-bindplane.sh
chmod +x /tmp/install-bindplane.sh
/tmp/install-bindplane.sh

############################
# CONFIGURATION
############################
mkdir -p /etc/bindplane

cat <<'EOF' > /etc/bindplane/config.yaml
apiVersion: bindplane.observiq.com/v1

eula:
  accepted: "2023-05-30"

license: |
  H4sIAAAAAAAA/...your-license-key...

env: production

network:
  host: 0.0.0.0
  port: "3001"

admin:
  auth:
    type: system
    username: admin
    password: StrongPassword@2026
    sessionSecret: d5a08be4-966b-47a3-9974-93061b84061c

store:
  type: postgres
  postgres:
    host: localhost
    port: "5432"
    database: bindplane
    username: bindplane
    password: StrongPassword@2025
    sslmode: disable
    schema: public
EOF

chown -R bindplane:bindplane /etc/bindplane
chmod 600 /etc/bindplane/config.yaml

############################
# INIT SCRIPT (AUTOMATION)
############################
cat <<'EOF' > /usr/local/bin/init-bindplane.sh
#!/bin/bash
set -e

BP_BIN="/usr/local/bin/bindplane"
CONFIG_FILE="/etc/bindplane/config.yaml"

# Check if Bindplane already initialized
if sudo -u postgres psql -d "bindplane" -c "\dt" >/dev/null 2>&1; then
  echo "BindPlane already initialized. Skipping init."
  exit 0
fi

# Stop Bindplane service if running
systemctl stop bindplane || true

# Non-interactive init with config file
sudo -u bindplane $BP_BIN init server \
  --accept-eula \
  --config $CONFIG_FILE \
  --license "H4sIAAAAAAAA/...your-license-key..." \
  --host "0.0.0.0" \
  --port 3001 \
  --remote-url "http://0.0.0.0:3001" \
  --auth "system" \
  --username "admin" \
  --password "StrongPassword@2026" \
  --db-type "postgres" \
  --db-host "localhost" \
  --db-port 5432 \
  --db-name "bindplane" \
  --db-user "bindplane" \
  --db-password "StrongPassword@2025" \
  --event-bus "local" \
  --auto-restart
EOF

chmod +x /usr/local/bin/init-bindplane.sh

############################
# RUN INIT + START SERVICE
############################
/usr/local/bin/init-bindplane.sh

systemctl daemon-reload
systemctl enable bindplane
systemctl restart bindplane

echo "=== STARTUP SCRIPT END ==="
SCRIPT
}
