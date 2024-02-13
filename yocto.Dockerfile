from debian:bullseye as base

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get -q update && apt-get upgrade -y -q && apt-get install -y -q apt-utils
RUN apt-get install -y -q \
    locales \
    && sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen \
    && locale-gen \
    && dpkg-reconfigure locales

ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8

RUN apt-get -q update && apt-get install -y -q \
    gawk \
    wget \
    curl \
    file \
    git-core \
    diffstat \
    unzip \
    texinfo \
    gcc-multilib \
    build-essential \
    chrpath \
    socat \
    cpio \
    python3 \
    python3-pip \
    python3-pexpect \
    xz-utils \
    debianutils \
    iputils-ping \
    python3-git \
    python3-jinja2 \
    libegl1-mesa \
    libsdl1.2-dev \
    pylint3 \
    xterm \
    python-is-python3 \
    python3-newt \
    && rm -rf /var/lib/apt/lists/*

RUN groupadd --gid 1000 user && useradd --uid 1000 --gid 1000 -m user

USER user
WORKDIR /enclaves

RUN pip3 install kas
ENV PATH=~/.local/bin:$PATH
