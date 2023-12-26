#!/bin/bash
# Script to join a peer to a channel
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_ID=cli
export CORE_PEER_ADDRESS=192.168.1.91:7003
export CORE_PEER_TLS_ROOTCERT_FILE=/vars/keyfiles/peerOrganizations/dealer.fish.com/peers/peer2.dealer.fish.com/tls/ca.crt
export CORE_PEER_LOCALMSPID=dealer-fish-com
export CORE_PEER_MSPCONFIGPATH=/vars/keyfiles/peerOrganizations/dealer.fish.com/users/Admin@dealer.fish.com/msp
export ORDERER_ADDRESS=192.168.1.91:7006
export ORDERER_TLS_CA=/vars/keyfiles/ordererOrganizations/example.com/orderers/orderer1.example.com/tls/ca.crt
if [ ! -f "voucherchannel.genesis.block" ]; then
  peer channel fetch oldest -o $ORDERER_ADDRESS --cafile $ORDERER_TLS_CA \
  --tls -c voucherchannel /vars/voucherchannel.genesis.block
fi

peer channel join -b /vars/voucherchannel.genesis.block \
  -o $ORDERER_ADDRESS --cafile $ORDERER_TLS_CA --tls
