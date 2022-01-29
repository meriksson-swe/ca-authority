#!/bin/bash
openssl req -config leaf/www.example.com.cnf -key leaf/private/www.example.com.key -new -sha256 -out leaf/csr/www.example.com.csr
