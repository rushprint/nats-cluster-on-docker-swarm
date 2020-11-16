#!/bin/sh

if [ -z $NATS_SEED_ADDRESS ]; then
# this is seed node : no --routes parameter.
    nats-server \
    -m 8222 \
    --cluster nats://0.0.0.0:6222 \
    --cluster_advertise $HOSTNAME \
    --connect_retries 20
else
# this is NOT seed node : join the cluster using --routes parameter.
    nats-server \
    -m 8222 \
    --cluster nats://0.0.0.0:6222 \
    --routes $NATS_SEED_ADDRESS \
    --cluster_advertise $HOSTNAME \
    --connect_retries 20
fi
