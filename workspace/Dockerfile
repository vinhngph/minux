# -------------------------------------------------------------------------------------------------
# BUILD
# -------------------------------------------------------------------------------------------------
FROM debian:stable-slim AS build

ARG GO_LANG_URL
ARG GO_LANG_CHECKSUM
ARG MAVEN_URL
ARG MAVEN_CHECKSUM
ARG GRADLE_URL
ARG GRADLE_CHECKSUM

WORKDIR /build

RUN apt-get update && apt-get full-upgrade -y && \
    apt-get install -y wget xz-utils unzip ca-certificates

# Golang
RUN echo "[-] Download Go from go.dev" && \
    wget -4 "${GO_LANG_URL}" -O go.tar.gz && \
    echo "[-] Verifying checksum..." && \
    echo "${GO_LANG_CHECKSUM}  go.tar.gz" | sha256sum -c - && \
    echo "[-] Checksum OK" && \
    tar -xzvf go.tar.gz

# Maven
RUN echo "[-] Download Maven from apache.org" && \
    wget -4 "${MAVEN_URL}" -O maven.tar.gz && \
    echo "[-] Verifying checksum..." && \
    echo "${MAVEN_CHECKSUM}  maven.tar.gz" | sha512sum -c - && \
    echo "[-] Checksum OK" && \
    mkdir maven && tar -xzvf maven.tar.gz -C ./maven --strip-components=1

# Gradle
RUN echo "[-] Download Gradle from gradle.org" && \
    wget -4 "${GRADLE_URL}" -O gradle.zip && \
    echo "[-] Verifying checksum..." && \
    echo "${GRADLE_CHECKSUM}  gradle.zip" | sha256sum -c - && \
    echo "[-] Checksum OK" && \
    mkdir tmp && unzip -d ./tmp gradle.zip && \
    mv ./tmp/* gradle

# -------------------------------------------------------------------------------------------------
# WORKSPACE
# -------------------------------------------------------------------------------------------------
FROM debian:stable

ARG USER_PASSWORD

# Environment variables
ENV LANG=en_US.UTF-8 \
    DEBIAN_FRONTEND=noninteractive \
    VIRTUAL_ENV_DISABLE_PROMPT=1 \
    TERM=xterm-256color

RUN sed -i 's|Components: main|Components: main contrib non-free non-free-firmware|' /etc/apt/sources.list.d/debian.sources && \
    apt-get update && apt-get full-upgrade -y && \
    # Install Locales
    apt-get install -y locales && \
    sed -i 's|# en_US.UTF-8 UTF-8|en_US.UTF-8 UTF-8|' /etc/locale.gen && \
    locale-gen && \
    # Install base packages
    apt-get install -y \
    sudo bash-completion ca-certificates vim gnupg alsa-utils pipewire pipewire-pulse pipewire-alsa wget curl git git-lfs ffmpeg libportaudio2 openjdk-21-jdk clamav extrepo openssh-server \
    # C/C++
    build-essential gdb \
    # Python
    python3 python3-full python3-dev \
    # Rust
    rustup \
    # ------------------------------------
    # End of installations
    && \
    # ------------------------------------
    # Update ClamAV databases
    freshclam && \
    # Bash completion
    rm /etc/apt/apt.conf.d/docker-clean && \
    # Clean trash and cache
    apt-get autoclean -y && apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* && \
    # Add user
    useradd -m -s /bin/bash friday && \
    if [ -z "${USER_PASSWORD:-}" ]; then \
    echo "USER_PASSWORD is not set" >&2; exit 1; \
    fi && \
    printf 'friday:%s\n' "${USER_PASSWORD}" | chpasswd && \
    usermod -aG sudo friday && \
    usermod -aG audio friday

# Setup NVIDIA Container Toolkit
RUN sed -i 's|# - contrib|- contrib|' /etc/extrepo/config.yaml && \
    sed -i 's|# - non-free|- non-free|' /etc/extrepo/config.yaml && \
    apt-get update && extrepo enable nvidia-cuda && \
    apt-get update && apt-get install -y cuda-toolkit && \
    rm -rf /var/lib/apt/lists/*
ENV PATH=${PATH}:/usr/local/cuda/bin

# Setup PostgreSQL
RUN apt-get update && extrepo enable postgresql && \
    apt-get update && apt-get install -y postgresql-client-18 && \
    rm -rf /var/lib/apt/lists/*

# Modify sudoers
RUN echo "Defaults    timestamp_timeout=0" > /etc/sudoers.d/90-custom-sudoers

USER friday

# Setup Golang
COPY --chown=friday:friday --from=build /build/go /home/friday/.local/bin/go
ENV PATH=${PATH}:/home/friday/.local/bin/go/bin

# Setup Maven
COPY --chown=friday:friday --from=build /build/maven /home/friday/.local/bin/maven
ENV PATH=${PATH}:/home/friday/.local/bin/maven/bin

# Setup Gradle
COPY --chown=friday:friday --from=build /build/gradle /home/friday/.local/bin/gradle
ENV PATH=${PATH}:/home/friday/.local/bin/gradle/bin

# Setup SFW
RUN npm i -g sfw

# Setup Rust
RUN rustup default stable

ENV XDG_RUNTIME_DIR=/run/user/1000 \
    SSH_AUTH_SOCK=/run/user/1000/keyring/ssh \
    GPG_AGENT_INFO=/run/user/1000/gnupg/S.gpg-agent:0:1 \
    COLORTERM=truecolor

COPY --chown=friday:friday .vimrc /home/friday
COPY --chown=friday:friday .bashrc /home/friday


RUN mkdir /home/friday/.ssh && \
    mkdir /home/friday/.gnupg && \
    mkdir /home/friday/workspace

WORKDIR /home/friday/workspace

USER root

CMD ["/usr/sbin/sshd", "-D"]
