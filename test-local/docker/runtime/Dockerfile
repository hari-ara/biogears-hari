FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    liblog4cpp5 \
    libxerces-c3.2 \
    ca-certificates && \
    rm -rf /var/lib/apt/lists/*

COPY lib/ /usr/local/lib/
COPY bin/ /usr/local/bin/
COPY build-metadata.json /opt/biogears/build-metadata.json

ENV LD_LIBRARY_PATH=/usr/local/lib

# Make sure binaries are executable
RUN chmod +x /usr/local/bin/* || echo "No binaries to make executable"

ENTRYPOINT ["/bin/bash", "-c", "if [ -x /usr/local/bin/bg-cli ]; then /usr/local/bin/bg-cli; else echo BioGears CLI Simulator; fi"]
