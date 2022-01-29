#!/bin/bash
openssl req -config intermediate/openssl.cnf -new -sha256 -key intermediate/private/ca.key -out intermediate/csr/intermediate.csr
