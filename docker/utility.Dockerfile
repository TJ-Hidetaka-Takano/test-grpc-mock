FROM ubuntu:22.04

# Installing debian packages
RUN apt-get update -qq \
  && DEBIAN_FRONTEND=noninteractive apt-get upgrade -y \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    bzip2 \
    ca-certificates \
    clang-format \
    clang-format-14 \
    curl \
    file \
    fonts-dejavu-core \
    g++ \
    gawk \
    git \
    jq \
    less \
    libxml2-utils \
    libz-dev \
    locales \
    make \
    netbase \
    openssh-client \
    patch \
    python3 \
    python3-setuptools \
    python3.10 \
    sudo \
    tzdata \
    uuid-runtime \
    vim \
    xz-utils \
  && rm -rf /var/lib/apt/lists/* \
  && localedef -i en_US -f UTF-8 en_US.UTF-8 \
  && useradd -m -s /bin/bash linuxbrew

# Setting up no passwd sudoers
RUN echo "Defaults:ALL env_keep += \"HTTP_PROXY HTTPS_PROXY http_proxy https_proxy no_proxy\"" \
  > /etc/sudoers.d/sudo_no_passwd \
  && echo "ALL ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers.d/sudo_no_passwd

RUN curl https://bootstrap.pypa.io/get-pip.py | python3 \
  && pip install --no-cache-dir pre-commit==3.1.0

RUN curl -fL https://github.com/mvdan/sh/releases/download/v3.6.0/shfmt_v3.6.0_linux_amd64 \
  > /usr/local/bin/shfmt \
  && chmod +x /usr/local/bin/shfmt

RUN curl -fL https://github.com/koalaman/shellcheck/releases/download/v0.9.0/shellcheck-v0.9.0.linux.x86_64.tar.xz \
  | tar Jx shellcheck-v0.9.0/shellcheck \
  && mv shellcheck-v0.9.0/shellcheck /usr/local/bin \
  && rmdir shellcheck-v0.9.0

RUN curl -fL https://github.com/bazelbuild/buildtools/releases/download/6.0.1/buildifier-linux-amd64 \
  > /usr/local/bin/buildifier \
  && chmod +x /usr/local/bin/buildifier

RUN curl -fsSL https://github.com/hadolint/hadolint/releases/download/v2.12.0/hadolint-Linux-x86_64 \
> /usr/local/bin/hadolint \
&& chmod +x /usr/local/bin/hadolint

# Installing linuxbrew
USER linuxbrew
RUN NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/homebrew/install/master/install.sh)"

# hadolint ignore=DL3002
USER root
RUN /home/linuxbrew/.linuxbrew/bin/brew shellenv | tee -a /etc/profile.d/linuxbrew.sh

ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8
ENV TZ=Asia/Tokyo

# Setting up entrypoint of the container
COPY --chmod=755 docker/entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/bash", "-li"]
