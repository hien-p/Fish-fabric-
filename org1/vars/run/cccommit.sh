#!/bin/bash
# Script to instantiate chaincode
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_ID=cli
export CORE_PEER_ADDRESS=192.168.1.91:7002
export CORE_PEER_TLS_ROOTCERT_FILE=/vars/keyfiles/peerOrganizations/supplier.fish.com/peers/peer1.supplier.fish.com/tls/ca.crt
export CORE_PEER_LOCALMSPID=supplier-fish-com
export CORE_PEER_MSPCONFIGPATH=/vars/keyfiles/peerOrganizations/supplier.fish.com/users/Admin@supplier.fish.com/msp
export ORDERER_ADDRESS=192.168.1.91:7006
export ORDERER_TLS_CA=/vars/keyfiles/ordererOrganizations/example.com/orderers/orderer1.example.com/tls/ca.crt
SID=$(peer lifecycle chaincode querycommitted -C voucherchannel -O json \
  | jq -r '.chaincode_definitions|.[]|select(.name=="voucher")|.sequence' || true)

if [[ -z $SID ]]; then
  SEQUENCE=1
else
  SEQUENCE=$((1+$SID))
fi

peer lifecycle chaincode commit -o $ORDERER_ADDRESS --channelID voucherchannel \
  --name voucher --version 6.0 --sequence $SEQUENCE \
  --peerAddresses 192.168.1.91:7002 \
  --tlsRootCertFiles /vars/discover/voucherchannel/supplier-fish-com/tlscert \
  --peerAddresses 192.168.1.91:7003 \
  --tlsRootCertFiles /vars/discover/voucherchannel/dealer-fish-com/tlscert \
  --cafile $ORDERER_TLS_CA --tls
