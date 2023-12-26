#!/bin/bash
cd $FABRIC_CFG_PATH
# cryptogen generate --config crypto-config.yaml --output keyfiles
configtxgen -profile OrdererGenesis -outputBlock genesis.block -channelID systemchannel

configtxgen -printOrg dealer-fish-com > JoinRequest_dealer-fish-com.json
configtxgen -printOrg supplier-fish-com > JoinRequest_supplier-fish-com.json
