#!/bin/bash
# Script to discover endorsers and channel config
cd /vars

export PEER_TLS_ROOTCERT_FILE=/vars/keyfiles/peerOrganizations/supplier.fish.com/users/Admin@supplier.fish.com/tls/ca.crt
export ADMINPRIVATEKEY=/vars/keyfiles/peerOrganizations/supplier.fish.com/users/Admin@supplier.fish.com/msp/keystore/priv_sk
export ADMINCERT=/vars/keyfiles/peerOrganizations/supplier.fish.com/users/Admin@supplier.fish.com/msp/signcerts/Admin@supplier.fish.com-cert.pem

discover endorsers --peerTLSCA $PEER_TLS_ROOTCERT_FILE \
  --userKey $ADMINPRIVATEKEY \
  --userCert $ADMINCERT \
  --MSP supplier-fish-com --channel voucherchannel \
  --server 192.168.1.91:7002 \
  --chaincode voucher | jq '.[0]' | \
  jq 'del(.. | .Identity?)' | jq 'del(.. | .LedgerHeight?)' \
  > /vars/discover/voucherchannel_voucher_endorsers.json

discover config --peerTLSCA $PEER_TLS_ROOTCERT_FILE \
  --userKey $ADMINPRIVATEKEY \
  --userCert $ADMINCERT \
  --MSP supplier-fish-com --channel voucherchannel \
  --server 192.168.1.91:7002 > /vars/discover/voucherchannel_config.json
