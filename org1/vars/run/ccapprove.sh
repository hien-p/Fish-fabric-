#!/bin/bash
# Script to approve chaincode
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_ID=cli
export CORE_PEER_ADDRESS=192.168.1.91:7002
export CORE_PEER_TLS_ROOTCERT_FILE=/vars/keyfiles/peerOrganizations/supplier.fish.com/peers/peer1.supplier.fish.com/tls/ca.crt
export CORE_PEER_LOCALMSPID=supplier-fish-com
export CORE_PEER_MSPCONFIGPATH=/vars/keyfiles/peerOrganizations/supplier.fish.com/users/Admin@supplier.fish.com/msp
export ORDERER_ADDRESS=192.168.1.91:7006
export ORDERER_TLS_CA=/vars/keyfiles/ordererOrganizations/example.com/orderers/orderer1.example.com/tls/ca.crt

peer lifecycle chaincode queryinstalled -O json | jq -r '.installed_chaincodes | .[] | select(.package_id|startswith("voucher_6.0:"))' > ccstatus.json

PKID=$(jq '.package_id' ccstatus.json | xargs)
REF=$(jq '.references.voucherchannel' ccstatus.json)

SID=$(peer lifecycle chaincode querycommitted -C voucherchannel -O json \
  | jq -r '.chaincode_definitions|.[]|select(.name=="voucher")|.sequence' || true)
if [[ -z $SID ]]; then
  SEQUENCE=1
elif [[ -z $REF ]]; then
  SEQUENCE=$SID
else
  SEQUENCE=$((1+$SID))
fi


export CORE_PEER_LOCALMSPID=dealer-fish-com
export CORE_PEER_TLS_ROOTCERT_FILE=/vars/keyfiles/peerOrganizations/dealer.fish.com/peers/peer2.dealer.fish.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=/vars/keyfiles/peerOrganizations/dealer.fish.com/users/Admin@dealer.fish.com/msp
export CORE_PEER_ADDRESS=192.168.1.91:7003

# approved=$(peer lifecycle chaincode checkcommitreadiness --channelID voucherchannel \
#   --name voucher --version 6.0 --init-required --sequence $SEQUENCE --tls \
#   --cafile $ORDERER_TLS_CA --output json | jq -r '.approvals.dealer-fish-com')

# if [[ "$approved" == "false" ]]; then
  peer lifecycle chaincode approveformyorg --channelID voucherchannel --name voucher \
    --version 6.0 --package-id $PKID \
    --sequence $SEQUENCE -o $ORDERER_ADDRESS --tls --cafile $ORDERER_TLS_CA
# fi

export CORE_PEER_LOCALMSPID=supplier-fish-com
export CORE_PEER_TLS_ROOTCERT_FILE=/vars/keyfiles/peerOrganizations/supplier.fish.com/peers/peer1.supplier.fish.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=/vars/keyfiles/peerOrganizations/supplier.fish.com/users/Admin@supplier.fish.com/msp
export CORE_PEER_ADDRESS=192.168.1.91:7002

# approved=$(peer lifecycle chaincode checkcommitreadiness --channelID voucherchannel \
#   --name voucher --version 6.0 --init-required --sequence $SEQUENCE --tls \
#   --cafile $ORDERER_TLS_CA --output json | jq -r '.approvals.supplier-fish-com')

# if [[ "$approved" == "false" ]]; then
  peer lifecycle chaincode approveformyorg --channelID voucherchannel --name voucher \
    --version 6.0 --package-id $PKID \
    --sequence $SEQUENCE -o $ORDERER_ADDRESS --tls --cafile $ORDERER_TLS_CA
# fi
