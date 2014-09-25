FROM ubuntu:14.04
MAINTAINER Vasileios Kalintiris <ehostunreach@gmail.com>

# install deps
RUN apt-get update
RUN apt-get install -qy build-essential subversion swig python2.7-dev libedit-dev libncurses5-dev  flex bison libglib2.0-dev libpixman-1-0 libpixman-1-dev
RUN apt-get install -qy git ccache make autoconf automake gcc g++ python python-dev build-essential pkg-config mercurial libsqlite3-dev npm sphinx-common libapache2-mod-wsgi python-pip apache2-dev apache2 clang libclang-dev vim
RUN ln -s /usr/bin/nodejs /usr/bin/node
RUN ln -s /usr/bin/llvm-config-3.4 /usr/bin/llvm-config
RUN pip install virtualenv virtualenvwrapper python-hglib nose

# download dxr
RUN mkdir -p /root/repos
WORKDIR /root/repos
RUN git clone --recursive https://github.com/mozilla/dxr.git

# ========== DXR ==========
WORKDIR /root/repos/dxr
RUN ./peep.py install -r requirements.txt
RUN python setup.py develop
RUN make
RUN cp ./trilite/libtrilite.so /usr/local/lib
RUN cp ./dxr/plugins/clang/libclang-index-plugin.so /usr/local/lib
RUN ldconfig

# ========== REPOS ==========
WORKDIR /root/repos

RUN git clone --depth 1 http://llvm.org/git/llvm.git
RUN git clone --depth 1 http://llvm.org/git/clang.git llvm/tools/clang
RUN git clone --depth 1 git://git.qemu-project.org/qemu.git
WORKDIR /root/repos/qemu
RUN git submodule update --init dtc

# ========== CFG ==========
COPY ./dxr.config /root/repos/dxr.config
RUN /bin/bash -c "/root/repos/dxr/bin/dxr-build.py -v /root/repos/dxr.config"
