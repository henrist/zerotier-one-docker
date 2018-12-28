# zerotier-one-docker

Docker container to run ZeroTier One using Docker.

## Run

Spawn the container in background:

```bash
docker run \
  -d \
  --restart unless-stopped \
  --name zerotier-one \
  --device /dev/net/tun \
  --net host \
  --cap-add NET_ADMIN \
  --cap-add SYS_ADMIN \
  -v /var/lib/zerotier-one:/var/lib/zerotier-one \
  henrist/zerotier-one
```

Show status of the service:

```bash
docker exec zerotier-one zerotier-cli status
```

Join a specific network:

```bash
docker exec zerotier-one zerotier-cli join NETWORK-ID
```

## Inspiration

See https://github.com/zyclonite/zerotier-docker
