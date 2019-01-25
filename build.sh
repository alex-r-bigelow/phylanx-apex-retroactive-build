#!/bin/bash

set -e

PROCS=$(lscpu | grep CPU.s.: | head -1 | cut -d: -f2)
USE_PROCS=$(($PROCS/2))

NOW=$(date +"%Y-%m-%dT%H:%M:%S")
BUILD_DATE=${1:-$NOW}
BUILD_DIR=${BUILD_DIR:-"$HOME/build-$BUILD_DATE"}
BUILD_FILE="$BUILD_DIR/setup.sh"
echo "Writing build file: $BUILD_FILE"
if [ -d $BUILD_DIR ]
then
  rm -rf $BUILD_DIR
fi
mkdir $BUILD_DIR
touch $BUILD_FILE
cd `dirname $0`
cp run.sh $BUILD_DIR

echo "#!/bin/bash" >> $BUILD_FILE
echo "BUILD_DATE=\"$BUILD_DATE\"" >> $BUILD_FILE

# Load modules
CLANG_VERSION=${CLANG_VERSION:-6.0.1}
echo "CLANG_VERSION=\"$CLANG_VERSION\"" >> $BUILD_FILE
module load clang/$CLANG_VERSION

CMAKE_VERSION=${CMAKE_VERSION:-3.9.0}
echo "CMAKE_VERSION=\"$CMAKE_VERSION\"" >> $BUILD_FILE
module load cmake/$CMAKE_VERSION

GPERFTOOLS_VERSION=${GPERFTOOLS_VERSION:-2.7}
echo "GPERFTOOLS_VERSION=\"$GPERFTOOLS_VERSION\"" >> $BUILD_FILE
module load gperftools/$GPERFTOOLS_VERSION

BOOST_VERSION=${BOOST_VERSION:-1.68.0-clang6.0.1-debug}
echo "BOOST_VERSION=\"$BOOST_VERSION\"" >> $BUILD_FILE
module load boost/$BOOST_VERSION

HWLOC_VERSION=${HWLOC_VERSION:-2.0.0}
echo "HWLOC_VERSION=\"$HWLOC_VERSION\"" >> $BUILD_FILE
module load hwloc/$HWLOC_VERSION

PAPI_VERSION=${PAPI_VERSION:-5.6.0}
echo "PAPI_VERSION=\"$PAPI_VERSION\"" >> $BUILD_FILE
module load papi/$PAPI_VERSION

BLAZE_VERSION=${BLAZE_VERSION:-3.4}
echo "BLAZE_VERSION=\"$BLAZE_VERSION\"" >> $BUILD_FILE
module load blaze/$BLAZE_VERSION

PYBIND11_VERSION=${PYBIND11_VERSION:-2.2.4}
echo "PYBIND11_VERSION=\"$PYBIND11_VERSION\"" >> $BUILD_FILE
module load pybind11/$PYBIND11_VERSION

PYTHON_VERSION=${PYTHON_VERSION:-3.6.3s}
echo "PYTHON_VERSION=\"$PYTHON_VERSION\"" >> $BUILD_FILE
module load python/$PYTHON_VERSION

INSTALL_DIR=${INSTALL_DIR:-$HOME/install}
if [ ! -d $INSTALL_DIR ]
then
  mkdir $INSTALL_DIR
fi
cd $INSTALL_DIR

# Install OTF2 if needed
OTF2_VERSION=${OTF2_VERSION:-2.1.1}
echo "OTF2_VERSION=\"$OTF2_VERSION\"" >> $BUILD_FILE
if [ ! -d $INSTALL_DIR/otf2 ]
then
  mkdir $INSTALL_DIR/otf2
fi
if [ ! -d $INSTALL_DIR/otf2/$OTF2_VERSION ]
then
  echo "Installing OTF2 $OTF2_VERSION"
  cd ~/
  wget http://www.vi-hps.org/upload/packages/otf2/otf2-$OTF2_VERSION.tar.gz
  tar -xzf otf2-$OTF2_VERSION.tar.gz
  cd otf2-$OTF2_VERSION
  ./configure CC=clang CXX=clang++ --prefix=$INSTALL_DIR/otf2/$OTF2_VERSION --enable-shared
  make -j $USE_PROCS
  make install
  cd ..
  rm -rf otf2-$OTF2_VERSION
  rm otf2-$OTF2_VERSION.tar.gz
fi

# Clone hpx if needed
if [ ! -d $INSTALL_DIR/hpx ]
then
  cd $INSTALL_DIR
  git clone https://github.com/STEllAR-GROUP/hpx.git
fi
cd $INSTALL_DIR/hpx
# Set the state of the hpx repository to what it was on the requested date
git checkout `git rev-list -1 --before="$BUILD_DATE" master`

# Build hpx
DEFAULT_HPX_PARAMS="\
 -DCMAKE_BUILD_TYPE=RelWithDebInfo \
 -DCMAKE_INSTALL_PREFIX=$BUILD_DIR/hpx \
 -DCMAKE_C_COMPILER=`which clang` \
 -DCMAKE_CXX_COMPILER=`which clang++` \
 -DHPX_WITH_MALLOC=tcmalloc \
 -DHPX_WITH_THREAD_IDLE_RATES=ON \
 -DHPX_WITH_PARCELPORT_MPI=OFF \
 -DHPX_WITH_PARCEL_COALESCING=OFF \
 -DHPX_WITH_TOOLS=OFF \
 -DHPX_WITH_DYNAMIC_HPX_MAIN=OFF \
 -DHPX_WITH_APEX=TRUE \
 -DHPX_WITH_APEX_TAG=develop \
 -DHPX_WITH_APEX_NO_UPDATE=FALSE \
 -DAPEX_WITH_ACTIVEHARMONY=FALSE \
 -DAPEX_WITH_OTF2=TRUE \
 -DOTF2_ROOT=$INSTALL_DIR/otf2/$OTF2_VERSION \
 -DBUILD_OTF2=FALSE \
 -DBUILD_ACTIVEHARMONY=FALSE \
 -DAPEX_WITH_PAPI=TRUE \
 -DHPX_WITH_MAX_CPU_COUNT=72"
HPX_PARAMS=${HPX_PARAMS:-$DEFAULT_HPX_PARAMS}
echo "HPX_PARAMS=\"$HPX_PARAMS\"" >> $BUILD_FILE
rm -rf build
mkdir build
cd build
cmake $HPX_PARAMS ..
make -j $USE_PROCS -l $USE_PROCS
make install

# Clone phylanx if needed
if [ ! -d $INSTALL_DIR/phylanx ]
then
  cd $INSTALL_DIR
  git clone https://github.com/STEllAR-GROUP/phylanx.git
fi
cd $INSTALL_DIR/phylanx
# Set the state of the phylanx repository to what it was on the requested date
git checkout `git rev-list -1 --before="$BUILD_DATE" master`

# Build Phylanx
DEFAULT_PHYLANX_PARAMS="\
  -DCMAKE_INSTALL_PREFIX=$BUILD_DIR/phylanx \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  -DCMAKE_CXX_COMPILER=`which clang++` \
  -DCMAKE_C_COMPILER=`which clang` \
  -DHPX_DIR=$INSTALL_DIR/hpx/build/lib/cmake/HPX \
  -Dblaze_DIR=$blaze_DIR \
  -Dpybind11_DIR=$pybind11_DIR"
PHYLANX_PARAMS=${PHYLANX_PARAMS:-$DEFAULT_PHYLANX_PARAMS}
echo "PHYLANX_PARAMS=\"$PHYLANX_PARAMS\"" >> $BUILD_FILE
rm -rf build
mkdir build
cd build
cmake $PHYLANX_PARAMS ..
make -j $USE_PROCS -l $USE_PROCS
make install
