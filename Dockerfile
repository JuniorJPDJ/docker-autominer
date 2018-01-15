FROM gw000/debian-cuda:8.0_7.0 AS build

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update -qq \
&& apt-get install --no-install-recommends -y \
    # needed to build miners
    git \
    # ccminer
    libcurl4-openssl-dev libssl-dev libjansson-dev automake autotools-dev build-essential \
    # needed to build autominer
    curl \
    libjson-xs-perl


# ccminer
ARG CCMINER_VERSION=2.2.4
WORKDIR /ccminer/
RUN wget https://github.com/tpruvot/ccminer/archive/${CCMINER_VERSION}-tpruvot.tar.gz -O ccminer.tar.gz && tar -xf ccminer.tar.gz
WORKDIR /ccminer/ccminer-${CCMINER_VERSION}-tpruvot/

# workaround for cuda apps to compile on debian stretch (no gcc5 in repo)
RUN sed -i '/nvcc_ARCH :=/i \
NVCC += -ccbin clang-3.8 \
' Makefile.am
# still not compiling

RUN ./build.sh
# TODO: install
WORKDIR /

# ccminer-cryptonight
ARG CCMINER_CRYPTONIGHT_VERSION=2.06
WORKDIR /ccminer-cryptonight/
RUN wget https://github.com/KlausT/ccminer-cryptonight/archive/${CCMINER_CRYPTONIGHT_VERSION}.tar.gz -O ccminer-cryptonight.tar.gz && tar -xf ccminer-cryptonight.tar.gz
WORKDIR /ccminer-cryptonight/ccminer-cryptonight-${CCMINER_CRYPTONIGHT_VERSION}/

RUN sed -i '/NVCC_GENCODE	=/i \
NVCC += -ccbin clang-3.8 \
' Makefile.am

RUN ./autogen.sh
RUN ./configure.sh
RUN make -j 4
# TODO: install


# 
