#!/usr/bin/env bash
#hellcheck disable=SC2086

PAUSE="$(curl -s http://localhost:8008/patroni | jq -r .pause)"

if [[ "${PAUSE}"  == "true" ]]; then
    echo "Patroni in pause mode."
    exit 0
fi

ROLE="$(curl -s http://localhost:8008/patroni | jq -r .role)"
case "$ROLE" in
  master|replica)
    echo $ROLE
    exit 0
  ;;
esac

echo "Current role: $ROLE"

pg_isready -U postgres || exit 1
echo "Postgres accepts connections"

exit 1
