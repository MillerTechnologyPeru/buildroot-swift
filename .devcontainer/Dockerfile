# [Choice] Swift version: 5.6-focal, 5.5, 5.4, 5.3, 5.2, 5.1, 4.2
ARG VARIANT=5.7-jammy
FROM swift:${VARIANT}

# [Option] Install zsh
ARG INSTALL_ZSH="true"
# [Option] Upgrade OS packages to their latest versions
ARG UPGRADE_PACKAGES="false"

# Install needed packages and setup non-root user. Use a separate RUN statement to add your own dependencies.
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID
COPY library-scripts/common-debian.sh /tmp/library-scripts/
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && /bin/bash /tmp/library-scripts/common-debian.sh "${INSTALL_ZSH}" "${USERNAME}" "${USER_UID}" "${USER_GID}" "${UPGRADE_PACKAGES}" "true" "true" \
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* && rm -rf /tmp/library-scripts

# [Choice] Node.js version: none, lts/*, 16, 14, 12, 10
ARG NODE_VERSION="none"
ENV NVM_DIR=/usr/local/share/nvm
ENV NVM_SYMLINK_CURRENT=true \
    PATH=${NVM_DIR}/current/bin:${PATH}
COPY library-scripts/node-debian.sh /tmp/library-scripts/
RUN bash /tmp/library-scripts/node-debian.sh "${NVM_DIR}" "${NODE_VERSION}" "${USERNAME}" \
    && rm -rf /var/lib/apt/lists/* /tmp/library-scripts

# Install dependencies
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true && apt-get -q update && \
    apt-get -q install -y \
    ninja-build \
    qemu-user-static \
    wget \
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
    cmake \
    neofetch \
    && rm -r /var/lib/apt/lists/*

# Download Swift toolchain
RUN set -e; \
    ARCH_NAME="$(dpkg --print-architecture)"; \
    url=; \
    case "${ARCH_NAME##*-}" in \
        'amd64') \
            OS_ARCH_SUFFIX=''; \
            ;; \
        'arm64') \
            OS_ARCH_SUFFIX='-aarch64'; \
            ;; \
        *) echo >&2 "error: unsupported architecture: '$ARCH_NAME'"; exit 1 ;; \
    esac; \
    SWIFT_WEBDIR="$SWIFT_WEBROOT/$SWIFT_BRANCH/$(echo $SWIFT_PLATFORM | tr -d .)$OS_ARCH_SUFFIX" \
    && SWIFT_BIN_URL="$SWIFT_WEBDIR/$SWIFT_VERSION/$SWIFT_VERSION-$SWIFT_PLATFORM$OS_ARCH_SUFFIX.tar.gz" \
    && SWIFT_SIG_URL="$SWIFT_BIN_URL.sig" \
    # - Grab curl here so we cache better up above
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -q update && apt-get -q install -y curl && rm -rf /var/lib/apt/lists/* \
    # - Download the GPG keys, Swift toolchain, and toolchain signature, and verify.
    && export GNUPGHOME="$(mktemp -d)" \
    && curl -fsSL "$SWIFT_BIN_URL" -o swift.tar.gz "$SWIFT_SIG_URL" -o swift.tar.gz.sig \
    && gpg --batch --quiet --keyserver keyserver.ubuntu.com --recv-keys "$SWIFT_SIGNING_KEY" \
    && gpg --batch --verify swift.tar.gz.sig swift.tar.gz \
    # - Unpack the toolchain, set libs permissions, and clean up.
    && mkdir -p /workspaces/swift \
    && tar -xzf swift.tar.gz --directory /workspaces/swift --strip-components=1 \
    && chmod -R o+r /usr/lib/swift \
    && rm -rf "$GNUPGHOME" swift.tar.gz.sig swift.tar.gz

ENV SWIFT_NATIVE_TOOLS = "/workspaces/swift/usr/bin"

# Download LLVM headers
RUN set -e; \
    mkdir -p /workspaces/llvm \
    && cd /workspaces/llvm \
    && wget https://github.com/colemancda/swift-armv7/releases/download/0.4.0/llvm-swift.zip \
    && unzip llvm-swift.zip \
    && rm -rf llvm-swift.zip

ENV SWIFT_LLVM_DIR = "/workspaces/llvm"

# Download Buildroot
ENV BUILDROOT_RELEASE=2022.08.1
RUN set -e; \
    cd /workspaces \
    && wget "https://buildroot.org/downloads/buildroot-$BUILDROOT_RELEASE.tar.gz" \
    && tar -xf "buildroot-$BUILDROOT_RELEASE.tar.gz" \
    && mv "buildroot-$BUILDROOT_RELEASE" buildroot \
    && rm -rf "buildroot-$BUILDROOT_RELEASE.tar.gz"

ENV BUILDROOT_DIR = "/workspaces/buildroot"