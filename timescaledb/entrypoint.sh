#!/bin/bash
envsubst < "$PGHOME/patroni/patroni.yaml.template" > "$PATRONI_DIR/patroni.yaml"
if [[ -d $PGDATA ]]; then
  echo "directory exist"
  echo "use chmod 700 to PGDATA"
  chmod 700 $PGDATA
else
  echo "PGDATA doesnt exist"
fi
echo "start init"
$PGHOME/init.sh &
echo "start patroni"
exec patroni $PATRONI_DIR/patroni.yaml
echo "patroni stop with exit code"
