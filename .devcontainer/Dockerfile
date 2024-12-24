FROM debian:12

# [Option] Specify Configuration
ARG DEFCONFIG="swift_arm64_defconfig"

# [Option] Install zsh
ARG INSTALL_ZSH="true"

# Define paths
ENV BUILDROOT_DIR=/workspaces/buildroot
ENV BUILDROOT_RELEASE=2024.02.9

# Install needed packages and setup non-root user.
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID
COPY library-scripts/common-debian.sh /tmp/library-scripts/
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && /bin/bash /tmp/library-scripts/common-debian.sh "${INSTALL_ZSH}" "${USERNAME}" "${USER_UID}" "${USER_GID}" "true" "true" "true" \
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* && rm -rf /tmp/library-scripts

# Install Swift and Buildroot dependencies
COPY library-scripts/install-dependencies.sh /tmp/library-scripts/
RUN apt-get update && \
    /bin/bash /tmp/library-scripts/install-dependencies.sh \
    && rm -rf /var/lib/apt/lists/* /tmp/library-scripts

# Create folder
RUN mkdir -p /workspaces && chown -R vscode:vscode /workspaces
RUN mkdir -p /tmp/build-scripts && chown -R vscode:vscode /tmp/build-scripts

# Run as user
USER vscode

# Download Buildroot
COPY build-scripts/download-buildroot.sh /tmp/build-scripts/
RUN /bin/bash /tmp/build-scripts/download-buildroot.sh && rm /tmp/build-scripts/download-buildroot.sh

# Configure Buildroot
COPY swift_glibc_defconfig /workspaces/buildroot/configs/
COPY build-scripts/configure-glibc.sh /tmp/build-scripts/
RUN /bin/bash /tmp/build-scripts/configure-glibc.sh && rm /tmp/build-scripts/configure-glibc.sh

# Fetch sources
COPY build-scripts/fetch-sources.sh /tmp/build-scripts/
RUN /bin/bash /tmp/build-scripts/fetch-sources.sh

# Build host tools
COPY build-scripts/build-host-tools.sh /tmp/build-scripts/
RUN /bin/bash /tmp/build-scripts/build-host-tools.sh && rm /tmp/build-scripts/build-host-tools.sh

# Remove config
RUN rm -rf /workspaces/buildroot/.config
