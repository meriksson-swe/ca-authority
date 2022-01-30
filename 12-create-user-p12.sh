#!/bin/bash
user="${1:-username}"
openssl pkcs12 -export -out users/private/${user}.p12 -inkey users/private/${user}.key -in users/certs/${user}.crt -certfile intermediate/certs/intermediate.crt
