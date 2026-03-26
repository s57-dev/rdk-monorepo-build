FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8

RUN apt-get update && apt-get install -y \
    build-essential chrpath cmake curl diffstat g++ g++-multilib gcc gcc-multilib \
    git git-flow git-man gosu jq llvm make python3.8 python3.8-dev python3.8-venv python3-pip \
    ripgrep sudo sysstat texinfo tk-dev tree wget xz-utils zip zstd \
    libbz2-dev libffi-dev libglib2.0-dev libldap2-dev liblzma-dev libncurses5-dev \
    libreadline-dev libsasl2-dev libsqlite3-dev libslang2-dev libssl-dev libxml2-dev \
    libxmlsec1-dev zlib1g-dev ant nnn locales \
    cpio gawk lz4 rsync \
    vim \
    python-is-python3 \
    && rm -rf /var/lib/apt/lists/*

RUN locale-gen en_US.UTF-8 && update-locale LANG=en_US.UTF-8

# Install kas
RUN python3.8 -m pip install --upgrade pip setuptools wheel && \
    python3.8 -m pip install kas pyyaml requests jinja2 markupsafe

RUN echo "builder ALL=NOPASSWD: ALL" > /etc/sudoers.d/builder-nopasswd && \
    chmod 660 /etc/sudoers.d/builder-nopasswd && \
    groupadd -g 30000 builder && \
    useradd -m -u 30000 -g 30000 --create-home --home-dir /builder -s /bin/bash builder

RUN mkdir -p /work && chown builder:builder /work

COPY container-entrypoint /container-entrypoint

WORKDIR /work

ENTRYPOINT ["/container-entrypoint"]
