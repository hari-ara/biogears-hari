FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
# Install basic dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    liblog4cpp5v5 \
    libxerces-c3.2 \
    ca-certificates && \
    rm -rf /var/lib/apt/lists/*
# Create directory structure
COPY lib/ /usr/local/lib/
COPY bin/ /usr/local/bin/
COPY build-metadata.json /opt/biogears/build-metadata.json
ENV LD_LIBRARY_PATH=/usr/local/lib
# Make sure binaries are executable
RUN chmod +x /usr/local/bin/*
ENTRYPOINT ["/usr/local/bin/bg-cli"]
