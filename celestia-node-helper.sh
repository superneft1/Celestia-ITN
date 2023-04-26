#!/bin/bash

#####################################################################
export CELESH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BACKUP_DIR="${CELESH}/celeshfiles/backups"
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
echo "5. Check celestia-lightd logs"
echo "6. Run Submit PayForBlob(PFB) transaction"
echo "7. Remove node"                
echo ""

read -p "Please select an option 1-7: " choice

case $choice in
  1)
    echo "Install node and setup systemd service"
    echo "Please wait..."
    if [ -f func.sh ]; then
      sudo rm func.sh
    fi    
    wget https://raw.githubusercontent.com/superneft1/Celestia-ITN/main/func.sh 
    sed -i 's/\r//' func.sh
    chmod +x func.sh
    sudo /bin/bash func.sh    
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
    echo "Check celestia-lightd logs"
    journalctl -u celestia-lightd.service -f
    ;;
  6)
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
  7)
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
  *)
    echo "Invalid option. Please select option 1-7."
    ;;
esac