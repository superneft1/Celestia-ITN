# Celestia-ITN

# Overview
`PayForBlob.sh` is the celestia light node PayForBlob script.
<br/>
`celestia-node-helper.sh` is a tool for celestia node.

# Usage

```
cd $HOME && rm celestia-node-helper.sh
wget https://raw.githubusercontent.com/superneft1/Celestia-ITN/main/celestia-node-helper.sh && sed -i 's/\r//' celestia-node-helper.sh && chmod +x celestia-node-helper.sh && sudo /bin/bash celestia-node-helper.sh
```

![image](https://user-images.githubusercontent.com/35297605/234550484-6b224abb-8931-4f84-bb97-0521d6c6df08.png)

# Celestia-node-helper options

### 1. Install node and setup systemd service
  + After the installation is complete, be sure to back up your mnemonic and run the 

You can find the address by running the following command in the celestia-node directory:
```
./cel-key list --node.type light --keyring-backend test --p2p.network <network>
```

### 2. Check node ID

### 3. Create new wallet

### 4. Backup Keys

### 5. Run Submit PayForBlob(PFB) transaction
  + Please request blockspacerace faucet before submit PFB.

### 6. Remove node
  + Before running this command you should backup the .celestia-light-blockspacerace-0/keys folder

### 7. Start celestia-lightd

### 8. Stop celestia-lightd

### 9. Check celestia-lightd

### 10. Check celestia-lightd
