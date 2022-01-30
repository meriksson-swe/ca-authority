#!/bin/bash
openssl req -config intermediate/openssl.cnf -new -sha256 -key intermediate/private/intermediate.key -out intermediate/csr/intermediate.csr
