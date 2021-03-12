FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN dpkg --add-architecture i386

RUN apt-get update && \
    apt-get install -yy curl build-essential wget nano git && \ 
    apt-get install -yy bzr jq pkg-config mesa-opencl-icd ocl-icd-opencl-dev libltdl7 libnuma1

#OPTEE qemu dependencies
RUN apt-get install -yy python cpio android-tools-adb android-tools-fastboot autoconf \
        automake bc bison build-essential ccache cscope curl device-tree-compiler \
        expect flex ftp-upload gdisk iasl libattr1-dev libcap-dev libcap-ng-dev \
        libfdt-dev libftdi-dev libglib2.0-dev libhidapi-dev libncurses5-dev \
        libpixman-1-dev libssl-dev libtool make \
        mtools netcat python-crypto python3-crypto python-pyelftools \
        python3-pycryptodome python3-pyelftools python3-serial \
        rsync unzip uuid-dev xdg-utils xterm xz-utils zlib1g-dev  

RUN wget http://archive.ubuntu.com/ubuntu/pool/universe/h/hwloc/libhwloc5_1.11.9-1_amd64.deb && \
    dpkg -i libhwloc5_1.11.9-1_amd64.deb

RUN ln -s /usr/lib/x86_64-linux-gnu/libhwloc.so.1 /usr/lib/x86_64-linux-gnu/libhwloc.so

RUN wget http://ftp.us.debian.org/debian/pool/main/i/icu/libicu63_63.2-3_amd64.deb
RUN dpkg -i libicu63_63.2-3_amd64.deb

RUN useradd -ms /bin/bash runner
USER runner
WORKDIR /home/runner
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1

# Install Rust
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y
RUN echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> $HOME/.zshrc
RUN echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> $HOME/.bashrc
RUN $HOME/.cargo/bin/rustup default nightly
RUN $HOME/.cargo/bin/rustup component add rust-src
RUN $HOME/.cargo/bin/rustup target add armv7-unknown-linux-gnueabihf
RUN $HOME/.cargo/bin/rustup target add aarch64-unknown-linux-gnu
RUN $HOME/.cargo/bin/rustup target add aarch64-unknown-linux-musl

COPY --chown=runner:runner ./install.sh .
COPY --chown=runner:runner ./config.sh .
COPY --chown=runner:runner ./start.sh .
