#!/bin/bash

PROCS=$(lscpu | grep CPU.s.: | head -1 | cut -d: -f2)
USE_PROCS=$(($PROCS/2))

# Install hwloc
HWLOC_RELEASE=v1.11
HWLOC_DIR=hwloc-1.11.12
wget "https://download.open-mpi.org/release/hwloc/$HWLOC_RELEASE/$HWLOC_DIR.tar.gz"
tar -xzf $HWLOC_DIR.tar.gz
cd $HWLOC_DIR
./configure --prefix=$INSTALL CC=`which clang` CXX=`which clang++`
make -j $USE_PROCS
make install
cd /
rm -rf $HWLOC_DIR
