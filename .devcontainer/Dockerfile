FROM debian:12

# [Option] Install zsh
ARG INSTALL_ZSH="true"

# [Option] Upgrade OS packages to their latest versions
ARG UPGRADE_PACKAGES="false"

# Define paths
ENV BUILDROOT_DIR=/workspaces/buildroot
ENV BUILDROOT_RELEASE=2024.02.9

# Install needed packages and setup non-root user.
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID
COPY library-scripts/common-debian.sh /tmp/library-scripts/
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && /bin/bash /tmp/library-scripts/common-debian.sh "${INSTALL_ZSH}" "${USERNAME}" "${USER_UID}" "${USER_GID}" "${UPGRADE_PACKAGES}" "true" "true" \
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* && rm -rf /tmp/library-scripts

# Install Swift and Buildroot Dependencies
COPY library-scripts/install-dependencies.sh /tmp/library-scripts/
RUN apt-get update && \
    /bin/bash /tmp/library-scripts/install-dependencies.sh \
    && rm -rf /var/lib/apt/lists/* /tmp/library-scripts

# Download Buildroot
COPY build-scripts/download-buildroot.sh /tmp/build-scripts/
RUN /bin/bash /tmp/build-scripts/download-buildroot.sh \
    && rm -rf /var/lib/apt/lists/* /tmp/build-scripts

# Compile host tools
COPY build-scripts/build-host-tools.sh /tmp/build-scripts/
RUN /bin/bash /tmp/build-scripts/build-host-tools.sh \
    && rm -rf /var/lib/apt/lists/* /tmp/build-scripts