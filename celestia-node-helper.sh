#!/bin/bash

#####################################################################
export CELESH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BACKUP_DIR="${CELESH}/celeshfiles/backups"
#####################################################################

celestiad() {
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
}

#####################################################################

echo ""
echo "███╗   ███╗ █████╗ ███████╗██╗███╗   ██╗ ██████╗"
echo "████╗ ████║██╔══██╗╚══███╔╝██║████╗  ██║██╔═══██╗"
echo "██╔████╔██║███████║  ███╔╝ ██║██╔██╗ ██║██║   ██║"
echo "██║╚██╔╝██║██╔══██║ ███╔╝  ██║██║╚██╗██║██║   ██║"
echo "██║ ╚═╝ ██║██║  ██║███████╗██║██║ ╚████║╚██████╔╝"
echo "╚═╝     ╚═╝╚═╝  ╚═╝╚══════╝╚═╝╚═╝  ╚═══╝ ╚═════╝"
echo ""

echo ""
echo "Welcome to Celestia node helper"
echo "Please select what you want to do"
echo "1. Install node and setup systemd service" 
echo "2. Check node ID"              
echo "3. Create new wallet"
echo "4. Backup keys"
echo "5. Run Submit PayForBlob(PFB) transaction"
echo "6. Remove node"
echo "7. Start celestia-lightd"
echo "8. Stop celestia-lightd"
echo "9. Check celestia-lightd status"
echo "10. Check celestia-lightd logs"                
echo ""

read -p "Please select an option 1-10: " choice

case $choice in
  1)
    echo "Install node and setup systemd service"
    echo "Please wait..."
    
    sudo apt update && sudo apt upgrade -y
    sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential git make ncdu -y
    sleep 2

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

    celestiad
    sleep 2
    
    sudo systemctl enable celestia-lightd    
    sudo systemctl start celestia-lightd  
    sleep 2

    echo ""
    echo -e "\e[32mPlease backup mnemonic\e[0m"
    echo ""
    echo "To run a node, enter the command below"
    echo "sudo systemctl enable celestia-lightd"
    echo "sudo systemctl start celestia-lightd"
  
    echo "Done"
    ;;
  2)
    echo "Check node ID"
    AUTH_TOKEN=$(celestia light auth admin --p2p.network blockspacerace)
    result=$(curl -X POST \
             -H "Authorization: Bearer $AUTH_TOKEN" \
             -H 'Content-Type: application/json' \
             -d '{"jsonrpc":"2.0","id":0,"method":"p2p.Info","params":[]}' \
             http://localhost:26658 | jq '.result')
    
    ID=$(echo "$result" | jq -r '.ID')
    echo "$result"
    echo ""
    echo "Your node ID: $ID"
    echo ""
    ;;  
  3)
    echo "Create new wallet"
    cd ~/celestia-node
    echo "Please Enter wallet name:"
    read new_wallet_name
    ./cel-key add $new_wallet_name --keyring-backend test --node.type light --p2p.network blockspacerace
    echo "Done"
    ;;
  4)
    echo "Backup keys"
    INFO=$(find $HOME/.celestia-light-blockspacerace-0/keys/keyring-test/ -name *.info|head -n1)
    ADDRESS=$(find $HOME/.celestia-light-blockspacerace-0/keys/keyring-test/ -name *.address|head -n1)
    if [ ! -z "$INFO" ] && [ ! -z "$ADDRESS" ]; then
        zip -r -j "$BACKUP_DIR"/backup-key-folder-"$fecha".tar.gz $HOME/.celestia-light-blockspacerace-0/keys 2>/dev/null
        echo "Your keys folder is saved in ""$BACKUP_DIR"""
        echo ""
        echo ""
    else
        echo ""
        echo "No keys were found in $HOME/.celestia-light-blockspacerace-0/keys/keyring-test/ "
        echo ""
    fi
    ;;
  5)
    echo "Run Submit PayForBlob(PFB) transaction"
    if [ -f PayForBlob.sh ]; then
      sudo rm PayForBlob.sh
    fi

    wget https://raw.githubusercontent.com/superneft1/Celestia-ITN/main/PayForBlob.sh
    sed -i 's/\r//' PayForBlob.sh
    chmod +x PayForBlob.sh
    sudo /bin/bash PayForBlob.sh
    echo "Done"
    ;;
  6)
    echo "Removing node..."
    echo "Please wait..."
    cd $HOME
    sudo systemctl stop celestia-lightd
    sudo systemctl disable celestia-lightd
    sudo rm /etc/systemd/system/celestia-lightd.service
    sudo systemctl daemon-reload
    rm -rf $HOME/celestia-node
    rm -rf $HOME/.celestia-light-blockspacerace-0
    echo "Done"
    ;;
  7)
    echo "Start celestia-lightd"
    sudo systemctl start celestia-lightd
    ;;
  8)
    echo "Stop celestia-lightd"
    sudo systemctl status celestia-lightd
    ;;
  9)
    echo "Check celestia-lightd status"
    sudo systemctl status celestia-lightd
    ;;
  10)
    echo "Check celestia-lightd logs"
    journalctl -u celestia-lightd.service -f
    ;;
  *)
    echo "Invalid option. Please select option 1-10."
    ;;
esac