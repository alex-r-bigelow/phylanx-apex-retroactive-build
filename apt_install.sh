#!/bin/bash

apt-get update && apt-get install -y \
  cmake \
  git \
  wget \
  clang \
  python3 \
  python3-dev \
  python3-pip \
  libblas-dev \
  liblapack-dev \
  libhdf5-dev
apt-get purge
apt-get clean
