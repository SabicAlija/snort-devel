FROM ubuntu:16.04

# Partially based on 
# https://sublimerobots.com/2017/07/installing-snort-3-b237-in-ubuntu

ENV DOWNLOAD_DIR 	/home/temp
ENV SNORT_DIR_AUTO	snort_auto
ENV SNORT_DIR_CMAKE	snort_cmake
ENV SNORT_PRJ_DIR	snort_project_cdt
ENV SNORT_DIR		/opt/snort
ENV SNORT_VER		3.0.0-239
ENV SNORT_VER_M		3.0.0
ENV SNORT_EXTRA_VER	1.0.0-239
ENV DAQ_VER		2.2.2
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
ENV JAVA_HOME 		/usr/lib/jvm/java-8-oracle

# Replace 1000 with your user / group id
RUN export uid=1000 gid=1000 && \
    mkdir -p /home/developer && \
    echo "developer:x:${uid}:${gid}:Developer,,,:/home/developer:/bin/bash" >> /etc/passwd && \
    echo "developer:x:${uid}:" >> /etc/group && \
    mkdir -p /etc/sudoers.d && \	
    echo "developer ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/developer && \
    chmod 0440 /etc/sudoers.d/developer && \
    chown ${uid}:${gid} -R /home/developer

# Needed tools
RUN apt-get update && apt-get install -y \
    wget \
    cmake-curses-gui \
    gdb

# Snort Dependencies ---------------------------------------------------------/
RUN apt-get install linux-headers-$(uname -r) -y

# Prerequisites
RUN apt-get install -y \
    build-essential \
    autotools-dev \
    libpcap-dev

# DAQ Prerequisites
RUN apt-get install -y \
    bison \
    flex

# Hyperscan Prerequisities
RUN apt-get install -y \
    python

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
RUN apt-get install -y \
    asciidoc \
    dblatex \
    source-highlight
    

# Download packages need for snort
# git clone https://github.com/snortadmin/snort3.git && \
# wget -qO- https://github.com/snortadmin/snort3/archive/master.tar.gz | tar xvz && \
# wget -qO- https://github.com/Xiche/libdaq/archive/v$DAQ_VER.tar.gz | tar xvz && \
RUN mkdir -p $DOWNLOAD_DIR && cd $DOWNLOAD_DIR && mkdir $SNORT_DIR_AUTO && mkdir $SNORT_DIR_CMAKE && \
    wget -qO- http://downloads.sourceforge.net/project/safeclib/libsafec-10052013.tar.gz | tar xvz && \
    wget -qO- http://www.colm.net/files/ragel/ragel-$RAGEL_VER.tar.gz | tar xvz && \
    wget -qO- https://dl.bintray.com/boostorg/release/$BOOST_VER/source/$BOOST_DIR.tar.gz | tar xvz && \
    wget -qO- https://github.com/01org/hyperscan/archive/v$HYPERSCAN_VER.tar.gz | tar xvz && \
    cd $SNORT_DIR_AUTO && \
    wget -qO- https://www.snort.org/downloads/snortplus/snort-$SNORT_VER-auto.tar.gz | tar xvz && \
    wget -qO- https://www.snort.org/downloads/snortplus/snort_extra-$SNORT_EXTRA_VER-auto.tar.gz | tar xvz && cd .. && \
    cd $SNORT_DIR_CMAKE && \
    wget -qO- https://www.snort.org/downloads/snortplus/snort-$SNORT_VER-cmake.tar.gz | tar xvz && \
    wget -qO- https://www.snort.org/downloads/snortplus/snort_extra-$SNORT_EXTRA_VER-cmake.tar.gz | tar xvz && cd .. && \
    wget -qO- https://www.snort.org/downloads/snortplus/daq-$DAQ_VER.tar.gz | tar xvz && \
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
    make && make install && ./bin/unit-hyperscan
    

# netmap
#WORKDIR $DOWNLOAD_DIR
#RUN git clone https://github.com/luigirizzo/netmap.git && \
#    cd netmap && ./configure --no-drivers && make && make install

# DAQ
WORKDIR $DOWNLOAD_DIR/daq-$DAQ_VER
RUN ./configure && make && make install && ldconfig

# Snort 3
WORKDIR $DOWNLOAD_DIR/$SNORT_DIR_CMAKE/snort-$SNORT_VER_M-a4
#RUN autoreconf -isvf && ./configure_cmake.sh --prefix=$SNORT_DIR && cd build && make -j 8 install
RUN ./configure_cmake.sh --prefix=$SNORT_DIR && cd build && make -j 8 install
RUN ln -s /opt/snort/bin/snort /usr/sbin/snort
#RUN sh -c "echo 'export LUA_PATH=/opt/snort/include/snort/lua/\?.lua\;\;' >> ~/.bashrc"
#RUN sh -c "echo 'export SNORT_LUA_PATH=/opt/snort/etc/snort' >> ~/.bashrc

# Snort Eclipse CDT Project
# WORKDIR $DOWNLOAD_DIR
# RUN mkdir $SNORT_PRJ_DIR && cd $SNORT_PRJ_DIR && \
#     cmake ../$SNORT_DIR_CMAKE/snort-$SNORT_VER_M-a4 -G"Eclipse CDT4 - Unix Makefiles"
WORKDIR /home/developer
RUN mkdir workspace && mkdir snort_p && \
    cp -r $DOWNLOAD_DIR/$SNORT_DIR_CMAKE/snort-$SNORT_VER_M-a4 snort_p/src && \
    cd snort_p && cmake src -G"Eclipse CDT4 - Unix Makefiles"


# Install java
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y  software-properties-common && \
    add-apt-repository ppa:webupd8team/java -y && \
    apt-get update && \
    echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
    apt-get install -y oracle-java8-installer && \
    apt-get clean

# Gtk, X11
RUN apt-get install -y \
    dbus-x11 \
    packagekit-gtk3-module \
    libcanberra-gtk-module \
    libcanberra-gtk-module \
    libcanberra-gtk3-module

# Eclipse CDT
WORKDIR $DOWNLOAD_DIR
RUN wget -qO- http://eclipse.mirror.rafal.ca/technology/epp/downloads/release/oxygen/R/eclipse-cpp-oxygen-R-linux-gtk-x86_64.tar.gz | tar xvz && \
    mv eclipse /opt/

# Fix dbus error message
#RUN dbus-uuidgen > /var/lib/dbus/machine-id
ENV NO_AT_BRIDGE 1

# Change permissions
RUN chmod 777 /home/developer
RUN chown -R developer:developer /home/temp/$SNORT_PRJ_DIR
RUN chmod 777 /home/temp

# Nautilus (File Explorer)
RUN apt-get install -y nautilus

# Add Eclipse Workspace (from git repository)
# ADD workspace /home/developer/workspace
VOLUME workspace:/home/developer/workspace_ext
RUN chown -R developer:developer /home/developer/workspace
RUN chmod 777 /home/developer/workspace

USER developer
RUN alias ll='ls -la'
CMD ["/bin/bash"]

