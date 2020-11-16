# NATS cluster on Docker Swarm

The [official documentation][official_toturial] explains how build nats-server cluster on docker swam.
But it is **Manual/Script method instead using docker-compose.yml** and prevents scaling nats cluster itself.

## Ideas

* Use "service name" to specify "seed" server address. --routes $SEED
* Use "hostname" of node server address. --cluster_advertise ${HOSTNAME}
* I tried [entrypoint:][endtrypoint] tag to specify generated values, but it does not support environment variable support.
* So I added a bootstrap script and used $NATS_SEED_ADDRESS environment variable to determine if work as seed or not.

```bash
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
```


## Running cluster

```bash
$ docker stack deploy -c docker-compose.yml nats
```


## Scaling cluster size

Initial cluster size is 3 (Seed 1, node 2). You can scale out the node.

```bash
$ docker service scale nats_server=4
```


## Client connection addresses

* There are 2 kind(Seed, Node) of nats-server in the network. On client it is natural to specify both of them ['nats://seed:4222', 'nats://server:4222'].
* However in my use case I just only specified 'nats://server:4222'. Seed wasted at first and will be used after a node down and client try to reconnect.

[official_toturial]: https://docs.nats.io/nats-server/nats_docker/docker_swarm
[docker_dns]: https://docs.docker.com/config/containers/container-networking/#dns-services
[endtrypoint]: https://docs.docker.com/compose/compose-file/#entrypoint

