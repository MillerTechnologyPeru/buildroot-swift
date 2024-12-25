#!/bin/bash
set -e

export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true

apt-get -q install -y \
    ninja-build \
    qemu-user-static \
    wget \
    curl \
    bash \
    bc \
    binutils \
    build-essential \
    bzip2 \
    cpio \
    g++ \
    gcc \
    git \
    gzip \
    libncurses5-dev \
    libedit-dev \
    make \
    mercurial \
    whois \
    patch \
    perl \
    python3 \
    rsync \
    sed \
    tar \
    unzip \
    file \
    bison \
    flex \
    binutils-gold \
    libicu-dev \
    libcurl4-openssl-dev \
    libedit-dev \
    libsqlite3-dev \
    libncurses-dev \
    libpython3-dev \
    libxml2-dev \
    pkg-config \
    uuid-dev \
    tzdata \
    libstdc++-12-dev \
    clang \