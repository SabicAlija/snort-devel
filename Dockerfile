FROM ubuntu:16.04

# Partially based on https://sublimerobots.com/2017/07/installing-snort-3-b237-in-ubuntu

ENV DOWNLOAD_DIR 	/home/temp
ENV SNORT_DIR		/opt/snort
ENV DAQ_VER		2.2.1
ENV HWLOC_VER		1.11.8
ENV LUAJIT_VER		2.0.5
ENV SSL_VER		1.1.0g
ENV PCAP_VER		1.8.1
ENV PCRE_VER		8.41
ENV PKG_CONFIG_VER	0.29.2
ENV ZLIB_VER 		1.2.11
ENV LIBSAFEC_VER	10052013
ENV RAGEL_VER		6.10
ENV BOOST_VER		1.64.0
ENV BOOST_DIR		boost_1_64_0
ENV HYPERSCAN_VER	4.5.1
# ENV LIBDNET_GIT	https://github.com/dugsong/libdnet.git
ENV LIBDNET_GIT		https://github.com/jncornett/libdnet.git
ENV LUA_PATH		/opt/snort/include/snort/lua/\?.lua\;\;
ENV SNORT_LUA_PATH      /opt/snort/etc/snort


# Needed tools
RUN apt-get update && apt-get install -y \
    wget

# Snort Dependencies #######################################
# RUN apt-get install linux-headers-$(uname -r) -y

# Prerequisites
RUN apt-get install -y \
    build-essential \
    autotools-dev \
    libpcap-dev

# DAQ Prerequisites
RUN apt-get install -y \
    bison \
    flex

# for compiling source from github
RUN apt-get install -y \
    libtool \
    git \
    autoconf

# Recommended software (optional)
RUN apt-get install -y \
    liblzma-dev \
    cpputest \
    libsqlite3-dev \
    cmake

# Documentation
# RUN apt-get install -y \
#    asciidoc \
#    dblatex \
#    source-highlight
    

# Download packages need for snort
# git clone https://github.com/snortadmin/snort3.git && \
# wget -qO- https://www.snort.org/downloads/snortplus/daq-$DAQ_VER.tar.gz | tar xvz && \
RUN mkdir -p $DOWNLOAD_DIR && cd $DOWNLOAD_DIR && \
    wget -qO- http://downloads.sourceforge.net/project/safeclib/libsafec-10052013.tar.gz | tar xvz && \
    wget -qO- http://www.colm.net/files/ragel/ragel-$RAGEL_VER.tar.gz | tar xvz && \
    wget -qO- https://dl.bintray.com/boostorg/release/$BOOST_VER/source/$BOOST_DIR.tar.gz | tar xvz && \
    wget -qO- https://github.com/01org/hyperscan/archive/v$HYPERSCAN_VER.tar.gz | tar xvz && \
    wget -qO- https://github.com/snortadmin/snort3/archive/master.tar.gz | tar xvz && \
    wget -qO- https://github.com/Xiche/libdaq/archive/v$DAQ_VER.tar.gz | tar xvz && \
    git clone $LIBDNET_GIT && \
    wget -qO- https://www.open-mpi.org/software/hwloc/v1.11/downloads/hwloc-$HWLOC_VER.tar.gz | tar xvz && \
    wget -qO- http://luajit.org/download/LuaJIT-$LUAJIT_VER.tar.gz | tar xvz && \
    wget -qO- https://www.openssl.org/source/openssl-$SSL_VER.tar.gz | tar xvz && \
    wget -qO- http://www.tcpdump.org/release/libpcap-$PCAP_VER.tar.gz | tar xvz && \
    wget -qO- ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-$PCRE_VER.tar.gz | tar xvz && \
    wget -qO- https://pkg-config.freedesktop.org/releases/pkg-config-$PKG_CONFIG_VER.tar.gz | tar xvz && \
    wget -qO- www.zlib.net/zlib-$ZLIB_VER.tar.gz | tar xvz

# Zlib
WORKDIR $DOWNLOAD_DIR/zlib-$ZLIB_VER
RUN ./configure && make && make install

# Pkg Config
WORKDIR $DOWNLOAD_DIR/pkg-config-$PKG_CONFIG_VER
RUN ./configure --with-internal-glib && make && make install

# PCAP
WORKDIR $DOWNLOAD_DIR/libpcap-$PCAP_VER
RUN ./configure && make && make install

# PCRE
WORKDIR $DOWNLOAD_DIR/pcre-$PCRE_VER
RUN ./configure && make && make install

# OpenSSL
WORKDIR $DOWNLOAD_DIR/openssl-$SSL_VER
RUN ./config && make && make install

# LuaJIT
WORKDIR $DOWNLOAD_DIR/LuaJIT-$LUAJIT_VER
RUN make && make install

# hwloc
WORKDIR $DOWNLOAD_DIR/hwloc-$HWLOC_VER
RUN ./configure && make && make install

# libdnet
WORKDIR $DOWNLOAD_DIR/libdnet
RUN ./configure && make && make install

# libsafec
WORKDIR $DOWNLOAD_DIR/libsafec-10052013
RUN ./configure && make && make install

# Ragel
WORKDIR $DOWNLOAD_DIR/ragel-$RAGEL_VER
RUN ./configure && make && make install

# Hyperscan
WORKDIR $DOWNLOAD_DIR
RUN mkdir hyperscan-$HYPERSCAN_VER-build && cd hyperscan-$HYPERSCAN_VER-build && \
    cmake -DCMAKE_INSTALL_PREFIX=/usr/local \
          -DBOOST_ROOT=$DOWNLOAD_DIR/$BOOST_DIR/ \
          ../hyperscan-$HYPERSCAN_VER && \
    make && make install

RUN cd $DOWNLOAD_DIR/hyperscan-$HYPERSCAN_VER-build/ && ./bin/unit-hyperscan
    

# netmap
#WORKDIR $DOWNLOAD_DIR
#RUN git clone https://github.com/luigirizzo/netmap.git && \
#    cd netmap && ./configure --no-drivers && make && make install

# DAQ
WORKDIR $DOWNLOAD_DIR/daq-$DAQ_VER
RUN ./configure && make && make install && ldconfig

# Snort 3
WORKDIR $DOWNLOAD_DIR/snort3-master
RUN autoreconf -isvf && ./configure --prefix=$SNORT_DIR && make && make install
RUN ln -s /opt/snort/bin/snort /usr/sbin/snort
#RUN sh -c "echo 'export LUA_PATH=/opt/snort/include/snort/lua/\?.lua\;\;' >> ~/.bashrc"
#RUN sh -c "echo 'export SNORT_LUA_PATH=/opt/snort/etc/snort' >> ~/.bashrc

WORKDIR /home/$DOWNLOAD_DIR
CMD ["/bin/bash"]

