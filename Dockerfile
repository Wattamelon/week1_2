FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y \
    bash \
    procps \
    htop \
    tree \
    vim \
    nano \
    curl \
    wget \
    net-tools \
    iproute2 \
    lsof \
    psmisc \
    grep \
    coreutils \
    findutils \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash agentuser

WORKDIR /app

USER agentuser

EXPOSE 15034

CMD ["/bin/bash"]   