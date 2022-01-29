#!/bin/bash

days="${1:-3650}"
openssl ca -config openssl.cnf -extensions v3_intermediate_ca -days $days -notext -md sha256 -in intermediate/csr/intermediate.csr -out intermediate/certs/ca.crt
chmod 444 intermediate/certs/ca.crt
