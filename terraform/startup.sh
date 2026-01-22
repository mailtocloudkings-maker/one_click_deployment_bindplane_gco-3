#!/bin/bash
set -e
LOG=/var/log/bindplane-startup.log
exec > >(tee -a $LOG) 2>&1

BP_BIN="/usr/local/bin/bindplane"

# Install dependencies
apt-get update -y
apt-get install -y curl postgresql-client

# Install Bindplane
curl -fsSL https://storage.googleapis.com/bindplane-op-releases/bindplane/latest/install-linux.sh -o /tmp/install-bindplane.sh
chmod +x /tmp/install-bindplane.sh
/tmp/install-bindplane.sh

# Configure Bindplane
mkdir -p /etc/bindplane
cat <<EOF > /etc/bindplane/config.yaml
apiVersion: bindplane.observiq.com/v1

eula:
  accepted: "2023-05-30"

license: |
  ${license_key}

env: production

network:
  host: 0.0.0.0
  port: "3001"

admin:
  auth:
    type: system
    username: ${admin_user}
    password: ${admin_pass}
    sessionSecret: $(uuidgen)

store:
  type: postgres
  postgres:
    host: ${db_host}
    port: "5432"
    database: ${db_name}
    username: ${db_user}
    password: ${db_pass}
    sslmode: disable
    schema: public
EOF

chown -R bindplane:bindplane /etc/bindplane
chmod 600 /etc/bindplane/config.yaml

# Init server
sudo -u bindplane $BP_BIN init server --accept-eula --config /etc/bindplane/config.yaml

systemctl enable bindplane
systemctl restart bindplane
