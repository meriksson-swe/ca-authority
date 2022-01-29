#!/bin/bash

days="${1:-7300}"

openssl req -config openssl.cnf -key private/ca.key -new -x509 -days $days -sha256 -extensions v3_ca -out certs/ca.crt

