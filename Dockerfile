FROM ubuntu

# Specify where to install everything, relative to the image root
ENV INSTALL=/install

WORKDIR /

# Copy helper scripts to install from various sources
COPY apt_install.sh /apt_install.sh
COPY pip_install.sh /pip_install.sh
COPY tar_install.sh /tar_install.sh
COPY git_install.sh /git_install.sh

# Build prerequisites
RUN ./apt_install.sh
RUN ./pip_install.sh
RUN ./tar_install.sh
RUN ./git_install.sh https://github.com/pybind/pybind11.git "-DPYBIND11_TEST=Off"
RUN ./git_install.sh https://bitbucket.org/blaze-lib/blaze.git "-DBLAZE_SMP_THREADS=C++11"
RUN ./git_install.sh https://github.com/STEllAR-GROUP/BlazeIterative.git "-Dblaze_DIR=$INSTALL/share/blaze/cmake"
RUN ./git_install.sh https://github.com/BlueBrain/HighFive.git "-DUSE_BOOST=Off"

# Build HPX
RUN ./git_install.sh https://github.com/STEllAR-GROUP/hpx.git "\
 -DCMAKE_BUILD_TYPE=RelWithDebInfo \
 -DCMAKE_INSTALL_PREFIX=. \
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
 -DOTF2_ROOT=$INSTALL/otf2/ \
 -DBUILD_OTF2=FALSE \
 -DBUILD_ACTIVEHARMONY=FALSE \
 -DAPEX_WITH_PAPI=TRUE \
 -DHPX_WITH_MAX_CPU_COUNT=72"

RUN ./git_install.sh https://github.com/STEllAR-GROUP/phylanx.git "\
  -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  -DCMAKE_CXX_COMPILER=`which clang++` \
  -DCMAKE_C_COMPILER=`which clang` \
  -DHPX_DIR=$INSTALL/hpx \
  -Dblaze_DIR=$INSTALL/blaze \
  -Dpybind11_DIR=$INSTALL/pybind11"

ENV APEX_OTF2=1
ENV APEX_CSV_OUTPUT=1
ENV APEX_TASKGRAPH_OUTPUT=1

ENV PYTHONPATH=$INSTALL/phylanx/python/build/lib.linux-x86_64-3.4

CMD /bin/bash
