FROM fedora
RUN yum install -y clang make cmake git \
    bzip2 hwloc-devel blas blas-devel lapack lapack-devel boost-devel \
    libatomic which compat-openssl10 vim-enhanced wget zlib-devel \
    python3-flake8 gdb sudo python36 openmpi-devel papi papi-devel

ENV CXX clang++
ENV CC clang 

ARG CPUS
#ENV PYVER 3.6.7
#RUN wget https://www.python.org/ftp/python/${PYVER}/Python-${PYVER}.tgz
#RUN tar xf Python-${PYVER}.tgz
#WORKDIR /Python-${PYVER}
#RUN dnf install -y openssl-devel
#RUN ./configure
#RUN make -j ${CPUS} install
#RUN pip3 install numpy
#RUN pip3 install tensorflow
#RUN pip3 install keras
#RUN pip3 install CNTK
WORKDIR /

RUN wget https://www.dyninst.org/sites/default/files/downloads/harmony/ah-4.6.0.tar.gz
RUN tar -xzf ah-4.6.0.tar.gz
COPY code_generator.cxx /activeharmony-4.6.0/code-server/code_generator.cxx
RUN cd activeharmony-4.6.0 && CFLAGS=-fPIC LDFLAGS=-fPIC make -j ${CPUS} install prefix=/usr/install/activeharmony

RUN wget https://www.vi-hps.org/cms/upload/packages/otf2/otf2-2.1.1.tar.gz
RUN tar -xzf otf2-2.1.1.tar.gz
RUN cd otf2-2.1.1 && ./configure CXX=clang++ CC=clang --prefix=/usr/install/otf2 --enable-shared && make -j ${CPUS} && make install

RUN wget http://ftp.gnu.org/gnu/binutils/binutils-2.32.tar.gz
RUN tar -xzf binutils-2.32.tar.gz
RUN cd binutils-2.32 && ./configure --prefix=/usr/install/binutils --disable-dependency-tracking --enable-interwork --disable-multilib --enable-shared --disable-nls --enable-64-bit-bfd --enable-install-libiberty && make -j ${CPUS} && make install

RUN git clone https://github.com/OpenMPToolsInterface/LLVM-openmp.git
RUN mkdir -p LLVM-openmp/build
RUN cd LLVM-openmp/build && cmake -DCMAKE_C_COMPILER=${CC} -DCMAKE_CXX_COMPILER=${CXX} -DCMAKE_INSTALL_PREFIX=/usr/install/ompt -DCMAKE_BUILD_TYPE=Release .. && make -j ${CPUS} && make install

#      -DCMAKE_CXX_FLAGS=-fPIC
#      -DCMAKE_EXE_LINKER_FLAGS=-fPIC
#      -DCMAKE_MODULE_LINKER_FLAGS=-fPIC
#RUN git clone --single-branch --branch 1.1.0 --depth=1 https://github.com/STEllAR-GROUP/hpx.git
RUN git clone https://github.com/STEllAR-GROUP/hpx.git
RUN cd hpx && git checkout 12dd432 #39860c82da9092fb0b8c1c30d56a7f8ab 
RUN mkdir -p /hpx/build && \
    cd /hpx/build && \
    cmake -DCMAKE_BUILD_TYPE=Debug \
      -DCMAKE_C_COMPILER=clang \
      -DCMAKE_CXX_COMPILER=clang++ \
      -DHPX_WITH_MALLOC=system \
      -DHPX_WITH_MORE_THAN_64_THREADS=ON \
      -DHPX_WITH_MAX_CPU_COUNT=80 \
      -DHPX_WITH_EXAMPLES=Off \
      -DHPX_WITH_APEX=TRUE \
      -DAPEX_WITH_ACTIVEHARMONY=TRUE -DACTIVEHARMONY_ROOT=/usr/install/activeharmony \
      -DAPEX_WITH_OTF2=TRUE -DOTF2_ROOT=/usr/install/otf2 \
      -DAPEX_WITH_PAPI=TRUE \
      -DHPX_WITH_APEX_TAG=v2.1.4 \
      .. 
RUN cd /hpx/build && make -j ${CPUS} 
RUN cd /hpx/build && make -j ${CPUS} install 

#RUN pip3 install pytest
#RUN git clone --depth 1 https://github.com/pybind/pybind11.git && \
#    mkdir -p /pybind11/build && \
#    cd /pybind11/build && \
#    cmake -DCMAKE_BUILD_TYPE=Debug -DPYBIND11_PYTHON_VERSION=${PYVER} .. && \
#    make -j ${CPUS} install 

#RUN git clone --depth 1 https://bitbucket.org/blaze-lib/blaze.git && \
#    mkdir -p /blaze/build && \
#    cd /blaze/build && \
#    cmake -DCMAKE_BUILD_TYPE=Debug -DBLAZE_SMP_THREADS=C++11 .. && \
#    make -j ${CPUS} install

#RUN git clone --depth 1 https://github.com/STEllAR-GROUP/blaze_tensor.git && \
#    mkdir -p /blaze_tensor/build && \
#    cd /blaze_tensor/build && \
#    cmake -DCMAKE_BUILD_TYPE=Debug .. && \
#    make -j ${CPUS} install 

#COPY build.sh /usr/local/bin/build.sh
#RUN chmod +x /usr/local/bin/build.sh

#RUN echo "ALL            ALL = (ALL) NOPASSWD: ALL" >> /etc/sudoers
#COPY phylanx.devenv /Dockerfile
#RUN useradd -m jovyan
#USER jovyan
#WORKDIR /home/jovyan
#ENV LD_LIBRARY_PATH /home/jovyan/install/phylanx/lib64:/usr/local/lib64:/home/jovyan/install/phylanx/lib/phylanx:/usr/lib64/openmpi/lib
#COPY bash.sh /home/jovyan/.bashrc
#CMD ["sleep","infinity"]
