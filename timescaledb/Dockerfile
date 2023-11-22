FROM timescale/timescaledb:2.10.1-pg14


ENV PGDATA=/var/lib/postgresql/volume/data \
 PATRONI_DIR=/patroni \
 LANG=en_US.utf8 \
 PGHOME=/home/postgres \
 HOME=/home/postgres \
 PATRONI_DIR=/patroni \
 PATRONICTL_CONFIG_FILE=/patroni/patroni.yaml \
 PATRONI_POSTGRESQL_DATA_DIR=/var/lib/postgresql/volume/data

COPY *.sh $PGHOME/
RUN apk add --no-cache python3 py3-pip gcc musl-dev libffi-dev openssl-dev python3-dev gettext curl jq \
    && pip3 install psycopg2==2.8.6 \
    && pip3 install patroni[kubernetes]==2.1.1 \
    && mkdir -p $PATRONI_DIR \
    && chown -R postgres:postgres $PGHOME  \
    && apk del gcc musl-dev libffi-dev openssl-dev \
    && chown -R postgres:postgres $PATRONI_DIR

WORKDIR $PGHOME

ENTRYPOINT ["/bin/bash", "/home/postgres/entrypoint.sh"]
