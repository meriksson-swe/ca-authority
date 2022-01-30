#!/bin/bash
user="${1:-username}"
openssl req -config users/openssl.cnf -key users/private/${user}.key -new -sha256 -out users/csr/${user}.csr
