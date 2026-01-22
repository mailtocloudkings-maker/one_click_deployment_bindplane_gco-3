#!/bin/bash
set -e

curl -fsSL https://storage.googleapis.com/bindplane-op-releases/bindplane/latest/install-linux.sh | bash

cat >/etc/bindplane/config.yaml <<EOF
apiVersion: bindplane.observiq.com/v1
eula:
  accepted: "2023-05-30"
license: |
  ${LICENSE}
network:
  host: 0.0.0.0
  port: "3001"
admin:
  auth:
    type: system
    username: admin
    password: ${ADMIN_PASS}
store:
  type: postgres
  postgres:
    host: ${DB_HOST}
    port: "5432"
    database: bindplane
    username: ${DB_USER}
    password: ${DB_PASSWORD}
    sslmode: disable
EOF

systemctl stop bindplane || true
bindplane init server --accept-eula --config /etc/bindplane/config.yaml || true
systemctl restart bindplane
