#!/bin/bash
cat > Dockerfile.test << 'EOD'
FROM ubuntu:20.04
RUN             echo '    apt-get install -y \' >> docker/biogears/Dockerfile.external
            echo '    build-essential \' >> docker/biogears/Dockerfile.external
            echo '    cmake \' >> docker/biogears/Dockerfile.external
            echo '    git \' >> docker/biogears/Dockerfile.external
            echo '    wget \' >> docker/biogears/Dockerfile.external
            echo '    libxml2-dev \' >> docker/biogears/Dockerfile.external
            echo '    libxerces-c-dev \' >> docker/biogears/Dockerfile.external
            echo '    liblog4cpp5-dev \' >> docker/biogears/Dockerfile.external
            echo '    libeigen3-dev && \' >> docker/biogears/Dockerfile.external
            echo '    rm -rf /var/lib/apt/lists/*' >> docker/biogears/Dockerfile.external
EOD
docker build -q -t test-external -f Dockerfile.test .
