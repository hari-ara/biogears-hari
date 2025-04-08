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
    liblog4cpp5-dev && \
    rm -rf /var/lib/apt/lists/*
# Create directory structure
RUN mkdir -p /artifacts/lib /artifacts/bin
# Create dummy artifacts for testing
RUN echo 'This is a dummy shared library' > /artifacts/lib/libbiogears.so && \
    echo 'This is a dummy static library' > /artifacts/lib/libbiogears.a && \
    echo "echo \"BioGears CLI Simulator\"" >> /artifacts/bin/bg-cli && \
    chmod +x /artifacts/bin/bg-cli
# Set working directory
WORKDIR /opt/biogears
CMD ["/bin/bash"]
