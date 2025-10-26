# ZeroTierBridge

A container to provide out-of-the-box bridging functionality to a ZeroTier network.

## Running

### Prerequisites

- Docker running as your logged in user (if `docker ps` runs then you're good, if not follow the link ->) - [Linux instructions here](https://docs.docker.com/engine/install/linux-postinstall/)

### ZeroTier UI Changes

Once running, log into your ZeroTier interface and approve the new device. Click the wrench next to the name and select 'Allow Ethernet Bridging.'

![brave_RxG5EgQinY](https://user-images.githubusercontent.com/1135584/129230874-76f80345-5389-46f7-b892-0692f41be20b.png)

You also need to add a static route into ZeroTier so that the traffic is routed correctly. Add this a bit larger than normal because of [longest prefix matching](https://en.wikipedia.org/wiki/Longest_prefix_match).

![brave_4wHd9zo193](https://user-images.githubusercontent.com/1135584/129230132-11bcfb72-7d9b-4b40-a4e5-72130c583077.png)

### Docker Compose

Edit the `ZT_NETWORKS` variable in `docker-compose.yml` to add your networks. Multi-arch images are published automatically; no architecture changes are needed.

Easiest way to bring up is via Docker Compose. Rename `docker-compose.yml.example` to `docker-compose.yml` and run `docker compose up -d`.

If you want to disable bridging, set `ZT_BRIDGE=false`. This can be done after the initial networks have been joined (just change the environment variable in the `docker-compose.yml` file and restart), as the ZeroTier config persists but IPTables forwarding is done on each container startup.

### OG Docker

`docker build -t zerotierbridge .`

`docker run --cap-add NET_ADMIN --cap-add NET_RAW --sysctl net.ipv4.ip_forward=1 -e ZT_NETWORKS="NETWORK_1 NETWORK_2" -e ZT_BRIDGE=true zerotierbridge:latest`

Add your network ID(s) into the `ZT_NETWORKS` argument, space separated.

Disable bridging by passing `ZT_BRIDGE=false`. This can be done after the initial networks have been joined (just restart the container), as the ZeroTier config persists but IPTables forwarding is done on each container startup.

#### Persistent Storage

If you would like the container to retain the same ZeroTier client ID on reboot, attach a volume as per the below.

`docker run --privileged -e ZT_NETWORKS=NETWORK_ID_HERE ZT_BRIDGE=true -v zt_config:/var/lib/zerotier-one/ zerotierbridge:latest`

#### Notes

If your host requires additional privileges for networking, you may need to add device and capabilities in your runtime configuration. The provided Docker Compose example includes `cap_add: [NET_ADMIN, NET_RAW]` and `sysctls` for IP forwarding.
