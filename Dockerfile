FROM ubuntu:16.04

ENV DOWNLOAD_DIR 	/home/temp
ENV ZLIB_VER 		1.2.11
ENV PKG_CONFIG_VER	0.29.2
ENV PCAP_VER		1.8.1
ENV PCRE_VER		8.41
ENV SSL_VER		1.1.0g


# Needed tools
RUN apt-get update && apt-get install -y \
    wget

# Snort Dependencies #######################################
# Autotools, Autoconf, CMake, C++ compiler
RUN apt-get install autotools-dev autoconf cmake g++ -y
RUN apt-get install flex bison -y



# Download packages need for snort
RUN mkdir -p $DOWNLOAD_DIR && cd $DOWNLOAD_DIR && \
    wget -qO- www.zlib.net/zlib-$ZLIB_VER.tar.gz | tar xvz && \
    wget -qO- https://pkg-config.freedesktop.org/releases/pkg-config-$PKG_CONFIG_VER.tar.gz | tar xvz && \
    wget -qO- http://www.tcpdump.org/release/libpcap-$PCAP_VER.tar.gz | tar xvz && \
    wget -qO- ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-$PCRE_VER.tar.gz | tar xvz && \
    wget -qO- https://www.openssl.org/source/openssl-$SSL_VER.tar.gz | tar xvz 


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


WORKDIR /home/$DOWNLOAD_DIR
CMD ["/bin/bash"]
