#!/bin/bash
set -e

export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true

# Buildroot mandatory packages (manual section "System requirements"),
# plus the optional ones we want available: menuconfig/xconfig/gconfig,
# every source-fetching backend, graph generation, docs and pkg-stats.
# `which` is part of debianutils on Debian 13; there is no separate package.
apt-get -q install -y \
    bash \
    bc \
    binutils \
    build-essential \
    bzip2 \
    cpio \
    debianutils \
    diffutils \
    file \
    findutils \
    g++ \
    gawk \
    gcc \
    gzip \
    locales \
    make \
    patch \
    perl \
    rsync \
    sed \
    tar \
    unzip \
    wget \
    libncurses-dev \
    qtbase5-dev \
    libglib2.0-dev \
    libgtk2.0-dev \
    bzr \
    cvs \
    curl \
    git \
    mercurial \
    openssh-client \
    subversion \
    graphviz \
    python3 \
    python3-setuptools \
    python3-matplotlib \
    python3-aiohttp \
    asciidoc \
    w3m

# Swift host toolchain and buildroot-swift build dependencies
apt-get -q install -y \
    ninja-build \
    qemu-user-static \
    whois \
    bison \
    flex \
    binutils-gold \
    libicu-dev \
    libcurl4-openssl-dev \
    libedit-dev \
    libsqlite3-dev \
    libpython3-dev \
    libxml2-dev \
    pkg-config \
    uuid-dev \
    tzdata \
    libstdc++-14-dev \
    clang \
    gnupg

# Swift 6.3.3 is based on LLVM 21, which trixie does not ship; use apt.llvm.org
curl -fsSL --retry 8 --retry-all-errors --retry-delay 15 https://apt.llvm.org/llvm-snapshot.gpg.key -o /etc/apt/trusted.gpg.d/apt-llvm-org.asc
echo "deb http://apt.llvm.org/trixie/ llvm-toolchain-trixie-21 main" > /etc/apt/sources.list.d/llvm-21.list
apt-get -q update
apt-get -q install -y llvm-21-dev
