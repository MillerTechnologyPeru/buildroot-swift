# [Choice] Swift version: 5.6-focal, 5.5, 5.4, 5.3, 5.2, 5.1, 4.2
ARG VARIANT=6.0.3-bookworm
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

# Define paths
ENV SWIFT_NATIVE_TOOLS=/workspaces/swift/usr/bin
ENV SWIFT_LLVM_DIR=/workspaces/llvm
ENV BUILDROOT_DIR=/workspaces/buildroot
ENV BUILDROOT_RELEASE=2024.02.9

# Install Dependencies
COPY library-scripts/install-dependencies.sh /tmp/library-scripts/
RUN apt-get update && \
    /bin/bash /tmp/library-scripts/install-dependencies.sh \
    && rm -rf /var/lib/apt/lists/* /tmp/library-scripts

# Install Swift compiler
COPY library-scripts/install-swift.sh /tmp/library-scripts/
RUN /bin/bash /tmp/library-scripts/install-swift.sh \
    && rm -rf /var/lib/apt/lists/* /tmp/library-scripts

# Download Buildroot
COPY build-scripts/download-buildroot.sh /tmp/build-scripts/
RUN /bin/bash /tmp/build-scripts/download-buildroot.sh \
    && rm -rf /var/lib/apt/lists/* /tmp/build-scripts

