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
    python3-distutils \
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
    gnupg

# Swift 6.3.3 is based on LLVM 21, which bookworm does not ship; use apt.llvm.org
curl -fsSL https://apt.llvm.org/llvm-snapshot.gpg.key -o /etc/apt/trusted.gpg.d/apt-llvm-org.asc
echo "deb http://apt.llvm.org/bookworm/ llvm-toolchain-bookworm-21 main" > /etc/apt/sources.list.d/llvm-21.list
apt-get -q update
apt-get -q install -y llvm-21-dev