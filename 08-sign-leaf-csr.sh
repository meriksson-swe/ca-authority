#!/bin/bash
days="${1:-365}"
openssl ca -config intermediate/openssl.cnf -extensions server_cert -days $days -notext -md sha256 -in leaf/csr/www.example.com.csr -out leaf/certs/www.example.com.crt
# To present a full ca-chain we need not only the server certificate but also the intermediate certificate it was signed by
cat leaf/certs/www.example.com.crt intermediate/certs/intermediate.crt > leaf/certs/www.example.com.chain.crt
