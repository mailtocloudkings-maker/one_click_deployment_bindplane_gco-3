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
  H4sIAAAAAAAA/REPLACE_ME

env: production

network:
  host: 0.0.0.0
  port: "3001"

admin:
  auth:
    type: system
    username: admin
    password: test
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
DB_NAME="bindplane"

if sudo -u postgres psql -d "$DB_NAME" -c "\dt" >/dev/null 2>&1; then
  echo "BindPlane already initialized. Skipping."
  exit 0
fi

sudo systemctl stop bindplane || true

printf "%s\n" \
"H4sIAAAAAAAA/1RVCXPayBL+K7HyUolfYb8Z3aLqVdbG5oqFY2wjwLPHXLKEERAOI0iyv32rWwzepJKJmKOPr7/++ruVK6tuSUI5dUJyllJfnrnU886iUNMz5WvfcaStU+laNWu9W2irbrXm8+eptmrWfDvTS6tu8ek6L/R6mb9YNUuXi3zJ1/l8ZtUtm9reGbXPKHkgpI5/x1bNWuXPM77eLMEas54ZK0N7y1gZScZKTWewRoyVRDNWCpsxzliZ2jW4GP4HvgljpbQ12xDi6OQ9Ht9NYFO+A0M2WvsJ+y6cRmBBwqvIT2EXFs0Z/imFz1ipQrgYBmZJBURA4SfNGCup+gBvwo8C//udsZJ7H1fwnDtwi8CWcNEJiRjbEMo13oXFXp0R/Qfs2hqMps4FrD7suAoC4LDIIAFfYFBFJooIvngw9sABWKPgRAQ5RGh/hkOFUAB+3FX4GHGKVB9CQ/zUX7AvcRueYxR+G5yCEyrMiUxPGSuDlDGB+EPeoQuP/SYcA2wWeBLGNsUAXfwJ8YXHSDVuQjkUxKzFAqoo6SH3MqIIiYSwQoGZnH9AHGEDdiP4EuiAVJmyMqUIiImBkv/C6kEBCEAXhYwBi6I3HGV3i+SCDRd8+mF4j3w4HSHO8RuCFUPOXUQNH4N5jumcGDCAl6VUFTnDECmIxQQgeQl+qt/IiFBhcpxi4RAJZBZ86V9gFIBdCHuprowrVQNDXgjZpN7rIcEUg0pODBRVVbFv/K8mV+mZZgrTpx9IRLgf/R/sanNGsWoEK0SO3HDeGVZyX9WZBd1d8Hxq1a0VX/KJnqkln/321v7ncl5YNUvxNbfqlt51F+NGx+8U8TZOrst4/7y9SUZlr4jXvatr2rsn3m3rsbxJ7uzxw2gf2/FunIwnvUZn1Zn1Pdl6zG/zblvY0Uy0HvObRvdV2d5U5mCzuVKt6Xo87O94ssIzWahMFFN/NOwvhO110ffkorwn8TaZNL88DOa7O/pMBy9k//iierfNy2HvSu46+TYfD7MtH3Yz1Zq+CrA/6ZTx5HEdP3TW8cPlY3x14Vf/LjneT2jGky3Etx8NuxkvBptxu5uJl8tMtPsLkQyILKbLm6L3Ku47q04x3Q/a3cUI3hTjTLR705tGdz0aZpdje7BR7Ti/nVysOgXNdHOwHw+7+85kvj3cuZNF9G2c9Ijcdfy4sc1F0nT7reZCtKddUaipdPq9u7w6k3YzkyTaiPbLv30txKw/lYWXiUbHHxfNlbQH0aFaf/6qyEAw4L1IURdvgBaeNrSkSFDkovi0n02NUGuvZhpSEKOi2OmoL0g86j19i44/bFSB4afPKNnXRvi0OjR7pTK+0VBsZOlcYiPdfYfH4UFCqlsEyY4Krr4ZsUNthYsb4jv4nTqo3SeH1g2qDsdRolGNHBQaMFapGdwQ+tgxODuCwqgUFY33ZlSk7nF4CRTdAJPC1NxzVFWCT+AFxaSc1ez7UV4wdo8f5LeUYg9HGsUBGzF6Q5uxTRoECich6F/KDQQUvYqnr0dVFocX1QwE1SqDNDkMxg0JwvT8WN7o78sA0b56SwDF1DcFksFhBm0ItX2DFRYdsRWKsU1oi/Qah9fH9yGga/tm8Ibii5m6OClwXEPB0Q315x+OdaGIHM4McmoqgMThDof5LqvZjXL7E8OqeVeYo7Nr4ez53xDhfWJMLAEGTAPlF9VYhnbjGANqKoYYnkogYIZkI4EpdoREcqj7A4xL16AtkGrqJG5QrNBzZoqBKcCCbFbuNWOvXRRpw5QoPTB0VrHLsn7+EwAA//99bv98mQkAAA==
" \
"0.0.0.0" \
"3001" \
"http://localhost:3001" \
"1" \
"admin" \
"test" \
"test" \
"postgres" \
"localhost" \
"5432" \
"bindplane" \
"disable" \
"100" \
"bindplane" \
"StrongPassword@2025" \
"local" \
"y" | sudo $BP_BIN init server --accept-eula --config /etc/bindplane/config.yaml

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
