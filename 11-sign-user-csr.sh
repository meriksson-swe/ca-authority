#!/bin/bash
user="${1:-username}"
openssl ca -config intermediate/openssl.cnf -extensions usr_cert -days 365 -notext -md sha256 -in users/csr/${user}.csr -out users/certs/${user}.crt
