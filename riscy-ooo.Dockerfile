FROM ubuntu:16.04 AS base

# General dependencies
RUN apt-get -q update && apt-get install -y -q --no-install-recommends \
    ca-certificates \
    curl \
    gawk \
    git \
    less \
    openssh-client \
    nano \
    python \
    python3 \
    wget

# Build-specific dependencies
RUN apt-get -q update && apt-get install -y -q --no-install-recommends \
    autoconf \
    automake \
    autotools-dev \
    libmpc-dev \
    libmpfr-dev \
    libgmp-dev \
    build-essential \
    bison \
    flex \
    texinfo \
    gperf \
    libtool \
    patchutils \
    bc \
    zlib1g-dev \
    device-tree-compiler \
    pkg-config \
    python3-ply \
    ghc \
    libghc-regex-compat-dev \
    libghc-syb-dev \
    libghc-old-time-dev \
    libghc-split-dev \
    tcl-dev

FROM base AS build-tools

WORKDIR /enclaves

RUN git clone https://github.com/verilator/verilator.git \
    && cd verilator \
    && git checkout tags/v3.916 \
    && autoconf \
    && ./configure \
    && make install

RUN git clone https://github.com/mit-enclaves/riscy-OOO.git \
    && cd riscy-OOO \
    && sed -i 's/git@github.com:/https:\/\/github.com\//g' .gitmodules \
    && git submodule update --init --recursive \
    && cd coherence && git checkout non_uniform_L2 && cd .. \
    && cd tools \
    && ./build.sh $(nproc)

RUN git clone --branch 2021.07 --recursive https://github.com/B-Lang-org/bsc.git \
    && cd bsc \
    && make install-src

ENV BSPATH="/enclaves/bsc/inst"
ENV BLUESPECDIR="${BSPATH}/lib"
ENV PATH="${BSPATH}/bin:${PATH}"

RUN git clone https://github.com/B-Lang-org/bsc-contrib.git \
    && cd bsc-contrib \
    && make PREFIX="${BSPATH}"

FROM build-tools AS riscy-ooo

RUN groupadd --gid 1000 user && useradd --uid 1000 --gid 1000 -m user
RUN chown -R user:user /enclaves

USER user
WORKDIR /enclaves

ENV BSPATH="/enclaves/bsc/inst"
ENV BLUESPECDIR="${BSPATH}/lib"
ENV PATH="${BSPATH}/bin:${PATH}"

# This is all fine, but it will end up producing a very large Docker image when built, currently 18GB.
# Ideally, we would reset our environment to the base...
#
# FROM base
#
# and then copy in only the build tools we need, e.g. just the binaries produced by
# ./build.sh, verilator, bluespec, and get rid of the super large riscv toolchain sources
#
# COPY --from=build-tools <paths we want to copy> <where we want to keep them in our final image>
#
# Also, riscy-OOO's .git is super large, easy place to trim.
#
# So, the next task for streamlining building more would be to tease out what all doesn't need to
# be retained in riscy-OOO, linux repos in order to build new processors, enclave binaries, run
# simulations, etc.
#
# To get an interactive shell in this Docker image:
#
# $ docker run -it --rm -v "${HOME}/src/enclaves:/enclaves:Z" -w /enclaves <name of image you built>
#
# This command would also mount your ~/src/enclaves folder to /enclaves (not sure if it would overwrite tbh)
# and also cd to /enclaves on boot
#
# I don't think you'd ever want to actually define the building of a processor within your Dockerfile,
# since in something like CI you'd create the Dockerfile that can build the processor, and then start
# the image w/ some args to actually go and build it and copy out the results. But, this is how you'd do it.
#
# RUN bash -c "\
#     cd riscy-OOO \
#     && . setup.sh \
#     && cd procs/RV64G_OOO \
#     && make build.verilator CORE_NUM=2 TSO_MM=true SECURE_FLUSH=true USER_CLK_PERIOD=32 SECURE_ARBITER=true SECURE_MSHR=true -j$(nproc) \
#     "
