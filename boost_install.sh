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
