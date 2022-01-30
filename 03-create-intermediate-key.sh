#!/bin/bash
openssl genrsa -aes256 -out intermediate/private/intermediate.key 4096
chmod 400 intermediate/private/intermediate.key
