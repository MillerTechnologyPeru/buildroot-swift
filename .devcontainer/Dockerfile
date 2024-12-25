FROM debian:12

# [Option] Install zsh
ARG INSTALL_ZSH="true"

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
