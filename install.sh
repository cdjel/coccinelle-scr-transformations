#!/bin/sh


usage() {
    echo "Usage: sh install.sh [number]. Number: 1, 2, or verify"
}

install_step1() {
 
    # tools for eBPF/XDP dev
    sudo apt update
    sudo apt-get install -y libelf-dev libbpf-dev
    sudo apt-get install -y linux-tools-common linux-tools-generic
    sudo apt-get install -y libpcap-dev

    #coccinelle dependencies
    sudo apt install -y ocaml ocaml-findlib
    sudo apt install -y autoconf automake autotools-dev 
    sudo apt install -y libtool
    sudo apt install -y python3 python3-dev python3-pip
    sudo apt install -y pkg-config build-essential
}

install_step2() {
    # coccinelle source
    cd ~
    if [ ! -d "coccinelle" ]; then
        git clone https://github.com/coccinelle/coccinelle.git
    fi
    cd coccinelle
    ./autogen
    ./configure
    make
    sudo make install
}

verify() {
    echo "......Check OS version......"
    lsb_release -a
    echo "\n......Check kernel version......"
    uname -r
    echo "\n......Check Coccinelle version......"
    spatch --version
    
}

if [ $# -ne 1 ]
    then usage
else
    if [ $1 = "verify" ]
        then verify
    elif [ $1 -eq 1 ]
        then install_step1
    elif [ $1 -eq 2 ]
        then install_step2
    else usage
    fi
fi