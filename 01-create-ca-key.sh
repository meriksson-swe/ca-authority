#!/bin/bash
openssl genrsa -aes256 -out private/ca.key 4096
chmod 400 private/ca.key

