# Electrumx-EvrNode 

A Docker container solution that combines a full Evrmore node with an ElectrumX server for EVR.

![Evrmore](https://raw.githubusercontent.com/EvrmoreOrg/Evrmore/master/share/pixmaps/evrmore128.png)

## Overview

This repository contains the necessary files to build a Docker image that runs both an Evrmore full node and an ElectrumX server. This setup allows users to run their own Evrmore infrastructure for wallet connections and blockchain exploration.

The solution consists of:
- A full Evrmore node that maintains a complete copy of the Evrmore blockchain
- An ElectrumX server that provides a lightweight interface for Electrum-based wallets to connect to the Evrmore network
- Automatic SSL certificate generation for secure connections
- Persistent storage for both blockchain data and ElectrumX database

## Quick Start

```bash
docker run -d --name evrx \
  -p 8817:8817 \
  -p 50001:50001 \
  -p 50002:50002 \
  -p 50004:50004 \
  -p 8000:8000 \
  -v evrmore-data:/home/evr/.evrmore \
  -v electrumx-data:/home/evr/electrumx \
  sebawilq/evrx:latest
```

## Components

### Dockerfile

The Dockerfile builds an Ubuntu-based container that:
1. Installs all necessary dependencies
2. Creates an 'evr' user for running the services
3. Downloads and installs Evrmore v1.0.5
4. Sets up a Python virtual environment
5. Installs ElectrumX from the EvrmoreOrg repository
6. Configures environment variables for both services
7. Exposes the necessary ports for external connections
8. Sets up the startup script

### start.sh

The start script handles:
1. Activation of the Python virtual environment
2. Generation of SSL certificates if they don't exist
3. Creation of the Evrmore configuration file if needed
4. Starting the Evrmore daemon in the background
5. Waiting for Evrmore to start before launching ElectrumX
6. Starting the ElectrumX server in the background
7. Keeping the container running and following the Evrmore logs

## Detailed Configuration

### Port Mappings

| Port | Service | Description |
|------|---------|-------------|
| 8817 | Evrmore | RPC port for Evrmore node |
| 50001 | ElectrumX | TCP port for wallet connections |
| 50002 | ElectrumX | SSL port for secure wallet connections |
| 50004 | ElectrumX | WebSocket port for web-based clients |
| 8000 | ElectrumX | RPC/localhost port |

### Volume Mappings

| Volume | Container Path | Description |
|--------|---------------|-------------|
| evrmore-data | /home/evr/.evrmore | Persistent storage for the Evrmore blockchain data |
| electrumx-data | /home/evr/electrumx | Persistent storage for the ElectrumX database |

## Building the Image

If you want to build the image yourself instead of using the pre-built one:

```bash
git clone https://github.com/WilQSL/Electrumx-EvrNode.git
cd Electrumx-EvrNode
docker build -t your-username/evrx .
```

## Initial Synchronization

When first starting the container, both the Evrmore node and ElectrumX server will need to synchronize with the network. This process can take a significant amount of time depending on your hardware and network connection.

The Evrmore node needs to download and validate the entire blockchain, while ElectrumX builds its database from the blockchain data. You can monitor the synchronization progress by checking the logs:

```bash
docker logs -f evrx
```

## Connecting to the Services

### Evrmore RPC

You can connect to the Evrmore RPC interface on port 8817. You'll need to set up authentication in the evrmore.conf file.

Example RPC command:
```bash
curl --user username:password --data-binary '{"jsonrpc":"1.0","id":"curltest","method":"getinfo","params":[]}' -H 'content-type: text/plain;' http://127.0.0.1:8817/
```

### ElectrumX

Electrum-compatible wallets can connect to your ElectrumX server using:
- TCP: port 50001
- SSL: port 50002
- WebSocket: port 50004

## Maintenance

### Updating the Container

To update to the latest version:

```bash
docker pull sebawilq/evrx:latest
docker stop evrx
docker rm evrx
# Run the docker run command again
```

### Backing Up Data

The blockchain and ElectrumX data are stored in Docker volumes. You can back these up using Docker's volume management commands:

```bash
# Create a backup of the Evrmore blockchain data
docker run --rm -v evrmore-data:/source -v $(pwd):/backup ubuntu tar -czvf /backup/evrmore-data-backup.tar.gz -C /source .

# Create a backup of the ElectrumX database
docker run --rm -v electrumx-data:/source -v $(pwd):/backup ubuntu tar -czvf /backup/electrumx-data-backup.tar.gz -C /source .
```

## Troubleshooting

### Common Issues

1. **Container exits immediately**: Check the logs with `docker logs evrx` to see if there are any error messages.

2. **ElectrumX not starting**: The ElectrumX server waits for the Evrmore node to start. If the Evrmore node fails to start, ElectrumX won't start either.

3. **Connection issues**: Make sure the ports are correctly mapped and not blocked by your firewall.

## License

Please refer to the original Evrmore and ElectrumX repositories for license information.

## Credits
- [SATORI Network](https://satorinet.io)
- [Evrmore Project](https://github.com/EvrmoreOrg/Evrmore)
- [ElectrumX](https://github.com/EvrmoreOrg/electrumx-evrmore)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
