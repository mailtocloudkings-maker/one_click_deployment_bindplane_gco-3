#!/bin/bash
set -e
curl -fsSL https://storage.googleapis.com/bindplane-op-releases/bindplane-agent/latest/install.sh -o /tmp/install-agent.sh
chmod +x /tmp/install-agent.sh
/tmp/install-agent.sh --server-url http://<BINDPLANE_VM_IP>:3001 --api-key ${bindplane_api_key}
