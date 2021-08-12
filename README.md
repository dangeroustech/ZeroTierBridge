# ZeroTierBridge

A container to provide out-of-the-box bridging functionality to a ZeroTier network.

## Running

`docker build -t zerotierbridge .`

`docker run --privileged -e ZT_NETWORK=NETWORK_ID_HERE zerotierbridge:latest`

Once running, log into your ZeroTier interface and approve the new device. Click the wrench next to the name and select 'Allow Ethernet Bridging.'

You also need to add a static route into ZeroTier so that the traffic is routed correctly. Add this a bit larger than normal because of [longest prefix matching](https://en.wikipedia.org/wiki/Longest_prefix_match).

![brave_4wHd9zo193](https://user-images.githubusercontent.com/1135584/129230132-11bcfb72-7d9b-4b40-a4e5-72130c583077.png)

### Caveat: Architecture

If you need to run this on a device with different architecture (a raspberry pi, for instance), then just edit line 3 of the Dockerfile.

If you were using a Raspberry Pi 4, you would change this to `ARCH=arm64` and the container will pull the correct ZeroTier installer.

## TODO

- Add docker-compose.yml
- Add kubernetes deployment YAML
