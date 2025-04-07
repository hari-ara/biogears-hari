FROM ubuntu:18.04
RUN apt update && apt -y install git wget ninja-build libncurses5-dev build-essential g++ automake libeigen3-dev liblog4cpp5-dev libxerces-c-dev libssl-dev zlib1g-dev curl pkg-config
WORKDIR /root/src

# Install a newer version of CMake (3.20.0 or higher as required)
RUN wget https://github.com/Kitware/CMake/releases/download/v3.23.1/cmake-3.23.1.tar.gz && \
    tar -xf cmake-3.23.1.tar.gz && \
    wget https://www.codesynthesis.com/download/xsd/4.0/linux-gnu/x86_64/xsd_4.0.0-1_amd64.deb && \
    dpkg -i xsd_4.0.0-1_amd64.deb

WORKDIR /root/src/cmake-3.23.1
RUN ./bootstrap --parallel=4 --prefix=/usr/local && make -j4 && make install
WORKDIR /opt/biogears