#!/bin/bash
openssl genrsa -aes256 -out intermediate/private/ca.key 4096
chmod 400 intermediate/private/ca.key
