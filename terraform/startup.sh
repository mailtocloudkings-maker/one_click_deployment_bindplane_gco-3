#!/bin/bash
set -e
LOG=/var/log/bindplane-startup.log
exec > >(tee -a $LOG) 2>&1

# OS packages
apt-get update -y
apt-get install -y curl postgresql-client

# Create config directory
mkdir -p /etc/bindplane

cat <<EOF > /etc/bindplane/config.yaml
apiVersion: bindplane.observiq.com/v1
env: production

network:
  host: 0.0.0.0
  port: "3001"

admin:
  auth:
    type: system
    username: "${bindplane_admin_user}"
    password: "${bindplane_admin_password}"
    sessionSecret: "$(uuidgen)"

store:
  type: postgres
  postgres:
    host: "${google_sql_database_instance.bindplane_postgres.ip_address[0].ip_address}"
    port: "5432"
    database: bindplane
    username: "${db_user}"
    password: "${db_password}"
    sslmode: disable
    schema: public

license: |
  ${bindplane_license}
EOF

# Download & install Bindplane
curl -fsSL https://storage.googleapis.com/bindplane-op-releases/bindplane/latest/install-linux.sh -o /tmp/install-bindplane.sh
chmod +x /tmp/install-bindplane.sh
/tmp/install-bindplane.sh

# Initialize Bindplane server non-interactively
bindplane init server --accept-eula --config /etc/bindplane/config.yaml

# Enable & start service
systemctl daemon-reload
systemctl enable bindplane
systemctl restart bindplane
