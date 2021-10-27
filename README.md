# ZeroTierBridge

A container to provide out-of-the-box bridging functionality to a ZeroTier network.

## Running

### Prerequisites

- Docker running as your logged in user (i.e. not having to run `sudo docker-compose xyz`) - [Linux instructions here](https://docs.docker.com/engine/install/linux-postinstall/)

### ZeroTier UI Changes

Once running, log into your ZeroTier interface and approve the new device. Click the wrench next to the name and select 'Allow Ethernet Bridging.'

![brave_RxG5EgQinY](https://user-images.githubusercontent.com/1135584/129230874-76f80345-5389-46f7-b892-0692f41be20b.png)

You also need to add a static route into ZeroTier so that the traffic is routed correctly. Add this a bit larger than normal because of [longest prefix matching](https://en.wikipedia.org/wiki/Longest_prefix_match).

![brave_4wHd9zo193](https://user-images.githubusercontent.com/1135584/129230132-11bcfb72-7d9b-4b40-a4e5-72130c583077.png)

### Docker Compose

**You need to edit the `ZT_NETWORKS` and `ARCH` variable in the `docker-compose.yml` file first to add your networks and make sure your acrhitecture is correct (see [this page](http://download.zerotier.com/debian/buster/pool/main/z/zerotier-one/) for examples, usually either amd64 or arm64)**

Easy one-liner for Docker Compose:

`docker-compose build && docker-compose up -d`

If you want to disable bridging, set `ZT_BRIDGE=false`. This can be done after the initial networks have been joined (just rebuild the container), as the ZeroTier config persists but IPTables forwarding is done on each container startup.

### OG Docker

`docker build -t zerotierbridge .`

`docker run --privileged -e ZT_NETWORKS=NETWORK_ID_HERE -e ZT_BRIDGE=true zerotierbridge:latest`

Add your network ID(s) into the `ZT_NETWORKS` argument, space separated.

Disable bridging by passing `ZT_BRIDGE=false`. This can be done after the initial networks have been joined (just rebuild the container), as the ZeroTier config persists but IPTables forwarding is done on each container startup.

#### Persistent Storage

If you would like the container to retain the same ZeroTier client ID on reboot, attach a volume as per the below.

`docker run --privileged -e ZT_NETWORKS=NETWORK_ID_HERE ZT_BRIDGE=true --volume zt1:/var/lib/zerotier-one/ zerotierbridge:latest`

#### Caveat: Architecture

If you need to run this on a device with different architecture (a raspberry pi, for instance), then just edit line 3 of the Dockerfile.

If you were using a Raspberry Pi 4, you would change this to `ARCH=arm64` and the container will pull the correct ZeroTier installer.

## TODO

- Add kubernetes deployment YAML
