#!/bin/sh

# The machine will reboot at the end of install_step1 

usage() {
    echo "Usage: sh install_server.sh [number]. Number: 1, 2, 3, or verify"
}

install_step1() {
    # kernel installation 
    cd ~
    sudo apt update && sudo apt upgrade
    # kernel 6.0
    mkdir -p tmp && cd tmp
    wget -c https://kernel.ubuntu.com/~kernel-ppa/mainline/v6.0/amd64/linux-headers-6.0.0-060000_6.0.0-060000.202210022231_all.deb
    wget -c https://kernel.ubuntu.com/~kernel-ppa/mainline/v6.0/amd64/linux-headers-6.0.0-060000-generic_6.0.0-060000.202210022231_amd64.deb
    wget -c https://kernel.ubuntu.com/~kernel-ppa/mainline/v6.0/amd64/linux-modules-6.0.0-060000-generic_6.0.0-060000.202210022231_amd64.deb
    wget -c https://kernel.ubuntu.com/~kernel-ppa/mainline/v6.0/amd64/linux-image-unsigned-6.0.0-060000-generic_6.0.0-060000.202210022231_amd64.deb
    sudo dpkg -i *.deb
    cd ..
    sudo reboot
}

install_step2() {

    rm -rf tmp   
    # tools for eBPF/XDP dev
    sudo apt-get install -y libelf-dev libbpf-dev
    sudo apt-get install -y linux-tools-common linux-tools-generic
    sudo apt-get install -y libpcap-dev

    # bpftool
    if ! command -v bpftool &> /dev/null
    then
        # minimal kernel source for tools
        wget https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/snapshot/linux-6.0.tar.gz
        tar -xf linux-6.0.tar.gz
        cd linux-6.0/tools/bpf/bpftool/
        make
        sudo make install
        cd ../../../../
        rm -rf linux-6.0.tar.gz
        rm -rf linux-6.0
    else
        echo "bpftool already installed"
    fi
    #coccinelle dependencies
    sudo apt install -y ocaml ocaml-findlib
    sudo apt install -y autoconf automake autotools-dev 
    sudo apt install -y libtool
    sudo apt install -y python3 python3-dev python3-pip
    sudo apt install -y pkg-config build-essential
}

install_step3() {
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
    find . -name "*.tar.gz" -delete
    find . -name "*.tar" -delete
    find . -name "*.tmp" -delete
}

verify() {
    echo "......Check OS version......"
    lsb_release -a
    echo "\n......Check kernel version......"
    uname -r
    echo "\n......Check bpftool version......"
    bpftool version
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
    elif [ $1 -eq 3 ]
        then install_step3
    else usage
    fi
fi