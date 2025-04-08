FROM biogears-arm64-external:latest
WORKDIR /opt/biogears
COPY . .
RUN mkdir -p build/artifacts/lib build/artifacts/bin
WORKDIR /opt/biogears/build
RUN cmake -DCMAKE_INSTALL_PREFIX=/opt/biogears/build/install -DARA_Biogears_BUILD_JAVATOOLS=OFF -DARA_Biogears_BUILD_HOWTOS=ON -DCMAKE_BUILD_TYPE=Release .. && make -j4
RUN make install
RUN mkdir -p /artifacts/lib /artifacts/bin
RUN cp -r install/lib/* /artifacts/lib/ && cp -r install/bin/* /artifacts/bin/
