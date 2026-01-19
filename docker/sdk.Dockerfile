# x86_64 Linux 開発環境
FROM ubuntu:24.04

ENV TZ=Asia/Tokyo

# Installing debian packages
RUN apt-get update -qq \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    autoconf \
    automake \
    build-essential \
    ca-certificates \
    curl \
    gcc \
    g++-14 \
    git \
    gpg \
    iproute2 \
    iputils-ping \
    jq \
    less \
    libboost-all-dev \
    libbz2-dev \
    libcgroup-dev \
    libtar-dev \
    libtool \
    libxml2-utils \
    locales \
    lsb-release \
    sudo \
    tzdata \
    unzip \
    vim \
    xz-utils \
    python3 \
    python3-pip \
    protobuf-compiler \
    libprotobuf-dev \
    protobuf-compiler-grpc \
    libgrpc++-dev \
    googletest \
    libgtest-dev \
    libgmock-dev \
  && curl https://apt.kitware.com/keys/kitware-archive-latest.asc | gpg --dearmor > /usr/share/keyrings/kitware-archive-keyring.gpg \
  && echo "deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ $(lsb_release -cs) main" > /etc/apt/sources.list.d/kitware.list \
  && apt-get update -qq \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    cmake=3.31.6-0kitware1ubuntu24.04.1 \
    cmake-data=3.31.6-0kitware1ubuntu24.04.1 \
    make \
    pkg-config \
  && rm -rf /var/lib/apt/lists/*

# Installing Python packages
RUN printf "[global]\nbreak-system-packages = true\n" > /etc/pip.conf \
  && pip3 install --no-cache-dir \
    grpcio-tools

# Setting up no passwd sudoers
RUN echo "Defaults:ALL env_keep += \"HTTP_PROXY HTTPS_PROXY http_proxy https_proxy no_proxy\"" \
  > /etc/sudoers.d/sudo_no_passwd \
  && echo "ALL ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers.d/sudo_no_passwd

# Setting up entrypoint of the container
COPY --chmod=755 docker/entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/bash", "-li"]

SHELL ["bash", "-c"]

# --- gRPC ---
# hadolint ignore=DL3003,SC2016
# RUN cd /tmp \
#   && git clone --depth=1 -b v1.52.1 --recursive https://github.com/grpc/grpc.git \
#   && mkdir -p grpc/build && cd grpc/build \
#   && cmake \
#     -DCMAKE_BUILD_TYPE=MinSizeRel \
#     -DgRPC_INSTALL=ON \
#     -DgRPC_BUILD_TESTS=OFF \
#     -DgRPC_BUILD_CSHARP_EXT=OFF \
#     -DgRPC_BUILD_GRPC_CPP_PLUGIN=ON \
#     -DgRPC_BUILD_GRPC_CSHARP_PLUGIN=OFF \
#     -DgRPC_BUILD_GRPC_NODE_PLUGIN=OFF \
#     -DgRPC_BUILD_GRPC_OBJECTIVE_C_PLUGIN=OFF \
#     -DgRPC_BUILD_GRPC_PHP_PLUGIN=OFF \
#     -DgRPC_BUILD_GRPC_PYTHON_PLUGIN=ON \
#     -DgRPC_BUILD_GRPC_RUBY_PLUGIN=OFF \
#     -DCMAKE_INSTALL_PREFIX=/usr .. \
#   && cmake --build . \
#   && cmake --install . \
#   && cd /tmp && rm -rf grpc*
