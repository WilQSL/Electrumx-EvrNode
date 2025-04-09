FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive


# check if we need all and hardcoded evrhash without compiling??
RUN apt-get update && apt-get install -y \
    wget \
    mc \
    python3.8 \
    python3-pip \
    python3-dev \
    libssl-dev \
    openssl \
    git \
    libleveldb-dev \
    cmake \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Create the evr user and necessary directories
RUN useradd -m -s /bin/bash evr \
    && mkdir -p /home/evr/.evrmore /home/evr/evrmore \
    && chown -R evr:evr /home/evr

# Download and extract Evrmore
RUN wget -O /tmp/evrmore.tar.gz https://github.com/EvrmoreOrg/Evrmore/releases/download/v1.0.5/evrmore-1.0.5-b0320a173-x86_64-linux-gnu.tar.gz \
    && tar -xzf /tmp/evrmore.tar.gz -C /home/evr/evrmore --strip-components=1 \
    && chown -R evr:evr /home/evr/evrmore \
    && rm -rf /tmp/evrmore.tar.gz

# Install virtualenv and create a Python environment
USER evr
RUN pip3 install --user virtualenv \
    && python3 -m virtualenv /home/evr/python_for_electrumx


# Install ElectrumX in the virtual environment
RUN . /home/evr/python_for_electrumx/bin/activate \
    && git clone https://github.com/EvrmoreOrg/electrumx-evrmore.git /home/evr/electrumx \
    && mkdir -p /home/evr/electrumx/electrumx_db \
    && cd /home/evr/electrumx \
    && pip3 install -r requirements.txt \
    && pip3 install websockets

# Set environment variables for Evrmore
ENV LD_LIBRARY_PATH="/home/evr/evrmore/lib"
ENV PATH="/home/evr/evrmore/bin:$PATH"

# Install evrhash in the virtual environment ( meybe I can copy it will be save some space and time)
RUN . /home/evr/python_for_electrumx/bin/activate \
    && git clone https://github.com/EvrmoreOrg/cpp-evrprogpow.git /home/evr/evrhash \
    && cd /home/evr/evrhash \
    && pip3 install . \
    && python3 -c "import evrhash; print('evrhash installed successfully')" \
    || (echo "Failed to install evrhash" && exit 1) \
    && rm -rf /home/evr/evrhash

# Set environment variables for ElectrumX
ENV DAEMON_URL="http://yourname:yourpassword@localhost:8819"
ENV COIN="Evrmore"
ENV NET="mainnet"
ENV DB_DIRECTORY="/home/evr/electrumx/electrumx_db"
ENV SERVICES="tcp://:50001,ssl://:50002,wss://:50004,rpc://localhost:8000"
ENV SSL_CERTFILE="/home/evr/electrumx/ssl_cert/server.crt"
ENV SSL_KEYFILE="/home/evr/electrumx/ssl_cert/server.key"
ENV COST_SOFT_LIMIT=100000
ENV COST_HARD_LIMIT=300000
ENV BANDWIDTH_UNIT_COST=1000
ENV CACHE_MB=750
ENV AIRDROP_CSV_FILE="/home/evr/electrumx/electrumx/airdropindexes.csv"

ENV PATH="/home/evr/python_for_electrumx/bin:$PATH"

# Expose ports (RPC and ElectrumX for electrumx just need 5002)
EXPOSE 8819 50001 50002 50004 8000

USER root
RUN chown -R evr:evr /home/evr/.evrmore /home/evr/electrumx

# Copy the startup script
COPY start.sh /home/evr/start.sh
RUN chown evr:evr /home/evr/start.sh && chmod +x /home/evr/start.sh
USER evr
CMD ["/home/evr/start.sh"]
