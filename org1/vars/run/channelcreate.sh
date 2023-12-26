#!/bin/bash
# Script to create channel block 0 and then create channel
cp $FABRIC_CFG_PATH/core.yaml /vars/core.yaml
cd /vars
export FABRIC_CFG_PATH=/vars
configtxgen -profile OrgChannel \
  -outputCreateChannelTx voucherchannel.tx -channelID voucherchannel

export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_ID=cli
export CORE_PEER_ADDRESS=192.168.1.91:7002
export CORE_PEER_TLS_ROOTCERT_FILE=/vars/keyfiles/peerOrganizations/supplier.fish.com/peers/peer1.supplier.fish.com/tls/ca.crt
export CORE_PEER_LOCALMSPID=supplier-fish-com
export CORE_PEER_MSPCONFIGPATH=/vars/keyfiles/peerOrganizations/supplier.fish.com/users/Admin@supplier.fish.com/msp
export ORDERER_ADDRESS=192.168.1.91:7007
export ORDERER_TLS_CA=/vars/keyfiles/ordererOrganizations/example.com/orderers/orderer2.example.com/tls/ca.crt
peer channel create -c voucherchannel -f voucherchannel.tx -o $ORDERER_ADDRESS \
  --cafile $ORDERER_TLS_CA --tls
