#!/usr/bin/env bash
# shellcheck disable=SC2086

set -e

until ($PGHOME/health-check.sh 1>/dev/null); do
        sleep 1
done

echo "SELECT E'CREATE ROLE active_user' WHERE NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'active_user')\gexec" | psql -U $PATRONI_SUPERUSER_USERNAME
echo "SELECT E'CREATE ROLE $ROOT_USERNAME WITH LOGIN PASSWORD \'$ROOT_PASSWORD\' IN ROLE active_user' WHERE NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = '$ROOT_USERNAME')\gexec" | psql -U $PATRONI_SUPERUSER_USERNAME
echo "SELECT 'CREATE DATABASE $ROOT_USERNAME WITH OWNER $ROOT_USERNAME' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '$ROOT_USERNAME')\gexec" | psql -U $PATRONI_SUPERUSER_USERNAME
echo "there is should be create extential timescaledb"

