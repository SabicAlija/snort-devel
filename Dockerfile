FROM ubuntu:16.04

ENV DOWNLOAD_DIR 	/home/temp
ENV SNORT_DIR		/opt/snort
ENV DAQ_VER		2.0.6
ENV HWLOC_VER		1.11.8
ENV LUAJIT_VER		2.0.5
ENV SSL_VER		1.1.0g
ENV PCAP_VER		1.8.1
ENV PCRE_VER		8.41
ENV PKG_CONFIG_VER	0.29.2
ENV ZLIB_VER 		1.2.11
# ENV LIBDNET_GIT	https://github.com/dugsong/libdnet.git
ENV LIBDNET_GIT		https://github.com/jncornett/libdnet.git



# Needed tools
RUN apt-get update && apt-get install -y \
    wget

# Snort Dependencies #######################################
# Autotools, Autoconf, CMake, C++ compiler
RUN apt-get install autotools-dev autoconf cmake g++ git libtool -y
RUN apt-get install flex bison -y
RUN apt-get install libpcap-dev cpputest -y
# RUN apt-get install linux-headers-$(uname -r) -y

# Download packages need for snort
RUN mkdir -p $DOWNLOAD_DIR && cd $DOWNLOAD_DIR && \
    git clone https://github.com/snortadmin/snort3.git && \
    wget -qO- https://www.snort.org/downloads/snort/daq-$DAQ_VER.tar.gz | tar xvz && \
    git clone $LIBDNET_GIT && \
    wget -qO- https://www.open-mpi.org/software/hwloc/v1.11/downloads/hwloc-$HWLOC_VER.tar.gz | tar xvz && \
    wget -qO- http://luajit.org/download/LuaJIT-$LUAJIT_VER.tar.gz | tar xvz && \
    wget -qO- https://www.openssl.org/source/openssl-$SSL_VER.tar.gz | tar xvz && \
    wget -qO- http://www.tcpdump.org/release/libpcap-$PCAP_VER.tar.gz | tar xvz && \
    wget -qO- ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-$PCRE_VER.tar.gz | tar xvz && \
    wget -qO- https://pkg-config.freedesktop.org/releases/pkg-config-$PKG_CONFIG_VER.tar.gz | tar xvz && \
    wget -qO- www.zlib.net/zlib-$ZLIB_VER.tar.gz | tar xvz


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
# -----------------------------------------------------------------------------
# Hwloc optional build support status:
# -----------------------------------------------------------------------------
# Probe / display I/O devices: PCI(linux)
# Graphical output (Cairo):    no
# XML input / output:          basic
# libnuma memory support:      no
# Plugin support:              no
# -----------------------------------------------------------------------------
WORKDIR $DOWNLOAD_DIR/hwloc-$HWLOC_VER
RUN ./configure && make && make install

# libdnet
WORKDIR $DOWNLOAD_DIR/libdnet
RUN ./configure && make && make install

# Zlib
WORKDIR $DOWNLOAD_DIR/zlib-$ZLIB_VER
RUN ./configure && make && make install

# netmap
#WORKDIR $DOWNLOAD_DIR
#RUN git clone https://github.com/luigirizzo/netmap.git && \
#    cd netmap && ./configure --no-drivers && make && make install

# DAQ
WORKDIR $DOWNLOAD/daq-$DAQ_VER
RUN ./configure && make && make install

# Snort 3

WORKDIR /home/$DOWNLOAD_DIR
CMD ["/bin/bash"]

