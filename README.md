# ZeroTierBridge

A container to provide out-of-the-box bridging functionality to a ZeroTier network.

## Running

`docker build -t zerotierbridge .`
`docker run --privileged -e ZT_NETWORK=NETWORK_ID_HERE zerotierbridge:latest`

Once running, log into your ZeroTier interface and approve the new device. Click the wrench next to the name and select 'Allow Ethernet Bridging.' It's that easy!

### Caveat: Architecture

If you need to run this on a device with different architecture (a raspberry pi, for instance), then just edit line 3 of the Dockerfile.

If you were using a Raspberry Pi 4, you would change this to `ARCH=arm64` and the container will pull the correct ZeroTier installer.

## TODO

- Add docker-compose.yml
- Add kubernetes deployment YAML
