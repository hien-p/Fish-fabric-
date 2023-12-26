#!/bin/bash
# Script to invoke chaincode
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_ID=cli
export CORE_PEER_ADDRESS=192.168.1.91:7002
export CORE_PEER_TLS_ROOTCERT_FILE=/vars/keyfiles/peerOrganizations/supplier.fish.com/peers/peer1.supplier.fish.com/tls/ca.crt
export CORE_PEER_LOCALMSPID=supplier-fish-com
export CORE_PEER_MSPCONFIGPATH=/vars/keyfiles/peerOrganizations/supplier.fish.com/users/Admin@supplier.fish.com/msp
export ORDERER_ADDRESS=192.168.1.91:7007
export ORDERER_TLS_CA=/vars/keyfiles/ordererOrganizations/example.com/orderers/orderer2.example.com/tls/ca.crt
peer chaincode invoke -o $ORDERER_ADDRESS --cafile $ORDERER_TLS_CA \
  --tls -C voucherchannel -n voucher  \
  --peerAddresses 192.168.1.91:7002 \
  --tlsRootCertFiles /vars/discover/voucherchannel/supplier-fish-com/tlscert \
  --peerAddresses 192.168.1.91:7003 \
  --tlsRootCertFiles /vars/discover/voucherchannel/dealer-fish-com/tlscert \
  -c '{"Args":["InitLedger"]}'
