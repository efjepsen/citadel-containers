from debian:bullseye as base

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get -q update && apt-get upgrade -y -q && apt-get install -y -q apt-utils
RUN apt-get install -y -q \
    locales \
    && sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen \
    && locale-gen \
    && dpkg-reconfigure locales

ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8

RUN apt-get -q update && apt-get install -y -q --no-install-recommends \
    bison \
    build-essential \
    ca-certificates \
    curl \
    flex \
    gawk \
    git \
    libexpat1-dev \
    texinfo \
    wget \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/riscv-collab/riscv-gnu-toolchain.git -b 2023.12.12

RUN pushd riscv-gnu-toolchain \
    && ./configure --prefix=/opt/riscv_linux/ --with-arch=rv64imafd \
    && make && make linux \
    && popd && rm -rf riscv-gnu-toolchain

RUN groupadd --gid 1000 user && useradd --uid 1000 --gid 1000 -m user
RUN chown -R user:user /opt/riscv_linux

USER user
WORKDIR /enclaves
ENV PATH=/opt/riscv_linux/bin:$PATH
