ARG OS_VERSION

FROM python:3.7.11-slim-${OS_VERSION}

ARG OS_VERSION
ARG TARGETOS
ARG TARGETARCH

RUN mkdir /finalBins

RUN apt-get update && \
  apt-get install -y gnupg wget && \
  apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927 && \
  wget -qO - https://www.mongodb.org/static/pgp/server-4.2.asc | apt-key add - && \
  echo "deb http://repo.mongodb.org/apt/debian $OS_VERSION/mongodb-org/4.2 main" > /etc/apt/sources.list.d/mongodb-org-4.2.list && \
  apt-get update

RUN if (apt-get install -y mongodb-org-shell mongodb-org-tools) \
  ; then \
    dpkg -L mongodb-org-shell mongodb-org-tools | grep /usr/bin/ | while read path; do mv "$path" /finalBins/; done \

  ; else \
    apt-get install -y git build-essential python3-pip libssl-dev libsasl2-dev libpcap-dev libcurl4-openssl-dev libboost-filesystem-dev libboost-program-options-dev libboost-system-dev libboost-thread-dev && \

    if $(dpkg --compare-versions $(dpkg-query -f='${Version}' --show gcc | sed -E 's/([0-9]:)?(.*)/\2/') lt 8.2); then \
      apt-get install -y flex curl && \
      git clone --depth 1 --branch releases/gcc-8.5.0 git://gcc.gnu.org/git/gcc.git && \
      cd gcc && \
      ./contrib/download_prerequisites && \
      ./configure --disable-multilib && \
      make -j $(nproc) && \
      make install \
    ; fi && \

    git clone --depth 1 --branch r4.2.18 https://github.com/mongodb/mongo /src/github.com/mongodb/mongo && \
    cd /src/github.com/mongodb/mongo && \
    python3 -m pip install -r etc/pip/compile-requirements.txt && \
    python3 buildscripts/scons.py $(if [ $(uname -m) = "aarch64" ]; then echo 'CCFLAGS="-march=armv8-a+crc"'; fi) mongo --disable-warnings-as-errors && \
    strip build/opt/mongo/mongo && \
    mv build/opt/mongo/mongo /finalBins/ && \

    wget https://go.dev/dl/go1.15.15.$TARGETOS-$TARGETARCH.tar.gz && \
    rm -rf /usr/local/go && \
    tar -C /usr/local -xzf go1.15.15.$TARGETOS-$TARGETARCH.tar.gz && \
    export PATH=$PATH:/usr/local/go/bin GOROOT=/usr/local/go && \

    git clone --depth 1 --branch r4.2.18 https://github.com/mongodb/mongo-tools /src/github.com/mongodb/mongo-tools && \
    cd /src/github.com/mongodb/mongo-tools && \
    ./build.sh ssl sasl && \
    strip bin/* && \
    mv bin/* /finalBins/ \
  ; fi
