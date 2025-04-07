#!/bin/bash
cat > Dockerfile.test << 'EOD'
FROM ubuntu:20.04
RUN           echo '    apt-get install -y --no-install-recommends \' >> docker-context/Dockerfile
          echo '    liblog4cpp5 \' >> docker-context/Dockerfile
          echo '    libxerces-c3.2 \' >> docker-context/Dockerfile
          echo '    ca-certificates && \' >> docker-context/Dockerfile
          echo '    rm -rf /var/lib/apt/lists/*' >> docker-context/Dockerfile
          echo '' >> docker-context/Dockerfile
          echo 'COPY lib/ /usr/local/lib/' >> docker-context/Dockerfile
          echo 'COPY bin/ /usr/local/bin/' >> docker-context/Dockerfile
          echo 'COPY build-metadata.json /opt/biogears/build-metadata.json' >> docker-context/Dockerfile
          echo '' >> docker-context/Dockerfile
EOD
docker build -q -t test-runtime -f Dockerfile.test .
