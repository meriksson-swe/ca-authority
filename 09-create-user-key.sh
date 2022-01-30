#!/bin/bash
user="${1:-username}"
openssl genrsa -out users/private/${user}.key 2048