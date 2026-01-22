#!/bin/bash
set -e

LOG=/var/log/bindplane-agent-startup.log
exec > >(tee -a $LOG) 2>&1

CONTROL_PLANE_URL="${control_plane_url}"
AGENT_TOKEN="${agent_token}"

echo "Installing Bindplane Agent..."

curl -fsSL https://storage.googleapis.com/bindplane-op-releases/agent/latest/install-linux.sh -o /tmp/install-agent.sh
chmod +x /tmp/install-agent.sh
/tmp/install-agent.sh

echo "Configuring Bindplane Agent..."

cat <<EOF > /etc/bindplane-agent/config.yaml
apiVersion: bindplane.observiq.com/v1

agent:
  id: $(hostname)
  auth:
    type: token
    token: ${AGENT_TOKEN}

controlPlane:
  endpoint: ${CONTROL_PLANE_URL}

logging:
  level: info
EOF

chown -R bindplane-agent:bindplane-agent /etc/bindplane-agent
chmod 600 /etc/bindplane-agent/config.yaml

systemctl enable bindplane-agent
systemctl restart bindplane-agent

echo "Bindplane Agent Installed & Connected"
