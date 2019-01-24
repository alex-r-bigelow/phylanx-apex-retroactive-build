#!/bin/bash

PROCS=$(lscpu | grep CPU.s.: | head -1 | cut -d: -f2)
USE_PROCS=$(($PROCS/2))

# Install boost
BOOST_RELEASE=1.67.0
BOOST_DIR=boost_1_67_0
wget "https://dl.bintray.com/boostorg/release/$BOOST_RELEASE/source/$BOOST_DIR.tar.gz"
tar -xzf $BOOST_DIR.tar.gz
cd $BOOST_DIR
./bootstrap.sh --prefix=$INSTALL --with-toolset=clang
./b2 --cxxflags=-std=c++11 -j $USE_PROCS
./b2 install
cd /
rm -rf $BOOST_DIR

# Install hwloc
HWLOC_RELEASE=v1.11
HWLOC_DIR=hwloc-1.11.12
wget "https://download.open-mpi.org/release/hwloc/$HWLOC_RELEASE/$HWLOC_DIR.tar.gz"
tar -xzf $HWLOC_DIR.tar.gz
cd $HWLOC_DIR
./configure --prefix=$INSTALL
make -j $USE_PROCS
make install
cd /
rm -rf $HWLOC_DIR

# Install OTF2
OTF2_DIR=otf2-2.1.1
wget http://www.vi-hps.org/upload/packages/otf2/$OTF2_DIR.tar.gz
tar -xzvf $OTF2_DIR.tar.gz temp
cd $OTF2_DIR
./configure CC=clang CXX=clang++ --prefix=$INSTALL/otf2 --enable-shared
make -j $USE_PROCS
make install
cd /
rm -rf $OTF2_DIR
