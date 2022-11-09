FROM ubuntu:22.10
MAINTAINER Hippie Hacker <hh@ii.coop>
RUN apt-get update && \
  DEBIAN_FRONTEND="noninteractive" apt-get install --yes \
  software-properties-common \
  ripgrep \
  fasd \
  libtool-bin \
  bash-completion \
  ca-certificates \
  curl \
  direnv \
  dnsutils \
  fd-find \
  file \
  gettext-base \
  git \
  gnupg2 \
  htop \
  iftop \
  iproute2 \
  iputils-ping \
  jq \
  kitty \
  less \
  locate \
  net-tools \
  openssh-client \
  sudo \
  tcpdump \
  tmux \
  tree \
  tzdata \
  unzip \
  vim \
  wget \
  xz-utils \
  sudo
# Created a ppa for emacs + broadway&nativecomp (build/Dockerfile has some of the process documented)
# We need a custom build to run against broadwayd
# https://launchpad.net/~hippiehacker/+archive/ubuntu/emacs-broadway
RUN add-apt-repository ppa:hippiehacker/emacs-broadway --yes && \
  DEBIAN_FRONTEND="noninteractive" apt-get install --yes emacs-snapshot emacs-snapshot-el
# Use upstream stable git
RUN add-apt-repository ppa:git-core/ppa --yes && \
  DEBIAN_FRONTEND="noninteractive" apt-get install --yes git

RUN chgrp coder -R /usr/local/bin && \
  chmod 775 -R /usr/local/bin

ARG KUBECTL_VERSION=1.24.2
RUN curl -L https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl \
    && chmod +x /usr/local/bin/kubectl

# Add a user `coder` so that you're not developing as the `root` user
RUN useradd coder \
    --create-home \
    --shell=/bin/bash \
    --uid=1000 \
    --user-group && \
    echo "coder ALL=(ALL) NOPASSWD:ALL" >>/etc/sudoers.d/nopasswd

USER coder

WORKDIR /home/coder

RUN git clone --depth 1 https://github.com/hlissner/doom-emacs ~/.emacs.d
RUN git clone --depth 1 https://github.com/humacs/.doom.d ~/.doom.d
RUN yes | $HOME/.emacs.d/bin/doom install --no-env
RUN $HOME/.emacs.d/bin/doom sync

# RUN $HOME/.emacs.d/bin/doom sync
# # COPY fonts/* /home/gitpod/.local/share/fonts/
# # RUN mkdir -p /home/gitpod/.local/share/fonts/
