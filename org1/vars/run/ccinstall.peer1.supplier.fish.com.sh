#!/bin/bash
# Script to install chaincode onto a peer node
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_ID=cli
export CORE_PEER_ADDRESS=192.168.1.91:7002
export CORE_PEER_TLS_ROOTCERT_FILE=/vars/keyfiles/peerOrganizations/supplier.fish.com/peers/peer1.supplier.fish.com/tls/ca.crt
export CORE_PEER_LOCALMSPID=supplier-fish-com
export CORE_PEER_MSPCONFIGPATH=/vars/keyfiles/peerOrganizations/supplier.fish.com/users/Admin@supplier.fish.com/msp
cd /go/src/github.com/chaincode/voucher


if [ ! -f "voucher_node_6.0.tar.gz" ]; then
  peer lifecycle chaincode package voucher_node_6.0.tar.gz \
    -p /go/src/github.com/chaincode/voucher/node/ \
    --lang node --label voucher_6.0
fi

peer lifecycle chaincode install voucher_node_6.0.tar.gz
