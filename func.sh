#!/bin/bash

update_packages() {
    sudo apt update && sudo apt upgrade -y
    sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential git make ncdu -y
    sleep 2
}

install_go() {
    ver="1.20" 
    cd $HOME 
    wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz" 
    sudo rm -rf /usr/local/go 
    sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz" 
    rm "go$ver.linux-amd64.tar.gz" 

    echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.bash_profile
    source $HOME/.bash_profile

    go version
    sleep 2
}

install_celestia_light_node () {

    LATEST_RELEASE=$(curl -s https://api.github.com/repos/celestiaorg/celestia-node/releases/latest | jq -r '.tag_name')
    echo "The latest Celestia Node release is: $LATEST_RELEASE"

    cd $HOME 
    rm -rf celestia-node 
    git clone https://github.com/celestiaorg/celestia-node.git 
    cd celestia-node/ 
    git checkout $LATEST_RELEASE
    make build 
    make install 
    make cel-key 
    celestia version 
    celestia light init --p2p.network blockspacerace 
    sleep 2
}

process (){
    update_packages
    install_go
    install_celestia_light_node
}

process

sudo tee <<EOF >/dev/null /etc/systemd/system/celestia-lightd.service
[Unit]
Description=celestia-lightd Light Node
After=network-online.target
 
[Service]
User=root
ExecStart=/usr/local/bin/celestia light start --core.ip https://rpc-blockspacerace.pops.one --core.rpc.port 26657 --core.grpc.port 9090 --keyring.accname my_celes_key --metrics.tls=false --metrics --metrics.endpoint otel.celestia.tools:4318 --gateway --gateway.addr localhost --gateway.port 26659 --p2p.network blockspacerace
Restart=on-failure
RestartSec=3
LimitNOFILE=4096
 
[Install]
WantedBy=multi-user.target
EOF

echo ""
echo -e "\e[32mPlease backup mnemonic\e[0m"
echo ""
echo "To check node logs, enter the command below"
echo "journalctl -u celestia-lightd -f"
echo ""
echo "To run a node, enter the command below"
echo "sudo systemctl enable celestia-lightd"
echo "sudo systemctl start celestia-lightd"