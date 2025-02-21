#!/bin/bash

# Activate the virtual environment
. /home/evr/python_for_electrumx/bin/activate

# Generate SSL certificates if they don’t exist
if [ ! -f "$SSL_CERTFILE" ] || [ ! -f "$SSL_KEYFILE" ]; then
    echo "SSL certificates do not exist, generating new ones..."
    mkdir -p /home/evr/electrumx/ssl_cert
    openssl genrsa -out "$SSL_KEYFILE" 2048
    openssl req -new -key "$SSL_KEYFILE" -out /tmp/server.csr -subj "/C=US/ST=Unknown/L=Unknown/O=EvrmoreElectrumX/CN=localhost"
    openssl x509 -req -days 1825 -in /tmp/server.csr -signkey "$SSL_KEYFILE" -out "$SSL_CERTFILE"
    rm -f /tmp/server.csr
    echo "SSL certificates generated: $SSL_CERTFILE and $SSL_KEYFILE"
else
    echo "SSL certificates already exist, skipping generation."
fi

# Check and create evrmore.conf if it doesn’t exist
if [ ! -f "/home/evr/.evrmore/evrmore.conf" ]; then
    echo "The evrmore.conf file does not exist, creating it..."
    echo -e "server=1\nwhitelist=127.0.0.1\ntxindex=1\naddressindex=1\nassetindex=1\ntimestampindex=1\nspentindex=1\nrpcallowip=127.0.0.1\nrpcuser=yourname\nrpcpassword=yourpassword\nuacomment=evrx\nmempoolexpiry=72\nrpcworkqueue=1100\nmaxmempool=2000\ndbcache=1000\nmaxtxfee=1.0\ndbmaxfilesize=64\nrest=1\nrpcport=8819" > /home/evr/.evrmore/evrmore.conf
    echo "The evrmore.conf file has been created."
else
    echo "The evrmore.conf file already exists."
fi

# Start evrmored in the background
echo "Starting Evrmore in the background..."
/home/evr/evrmore/bin/evrmored -datadir=/home/evr/.evrmore -conf=/home/evr/.evrmore/evrmore.conf -rpcport=8819 &

# Wait 60 seconds before starting ElectrumX or more less idk electrumx will be waiting anyway to full chain sync
echo "Waiting 60 seconds before starting ElectrumX..."
sleep 60

# Start ElectrumX in the background with logs redirected
echo "Starting ElectrumX in the background..."
/home/evr/electrumx/electrumx_server > /home/evr/electrumx/electrumx.log 2>&1 &

# Keep the container running
echo "Container is running, following evrmored logs..."
tail -f /home/evr/.evrmore/debug.log