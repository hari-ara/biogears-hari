FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Install basic dependencies
RUN apt-get update && \
    apt-get install -y \
    build-essential \
    cmake \
    git \
    wget \
    libxml2-dev \
    libxerces-c-dev \
    liblog4cpp5-dev \
    libeigen3-dev && \
    rm -rf /var/lib/apt/lists/*

# Handle architecture-specific package installation
# Skip CodeSynthesis XSD in local testing to avoid architecture issues
RUN echo "Skipping XSD installation for local testing"

ENV PATH="/usr/local/bin:${PATH}"
WORKDIR /opt/biogears

CMD ["/bin/bash"]
