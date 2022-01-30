#!/bin/bash
# Specify needed resource
root_dirs_needed='certs crl newcerts private'
inter='intermediate'
intermediate_dirs_needed='certs crl csr newcerts private'
leaf='leaf'
leaf_dirs_needed='certs csr newcerts private'
files_needed='index.txt serial crlnumber'
user='users'
user_dirs_needed='certs csr private'

function print_ca_config() {
dir=$1
fil=$2
policy=$3
cert_name='ca'
if [ "loose" == "$policy" ]; then
  extra='req_extensions      = req_ext'
  cert_name='intermediate'
fi

cat <<EOF > $dir/$fil
[ ca ]
# 'man ca'
default_ca = CA_default

[ CA_default ]
# Directory and file locations.
dir               = ${dir}
certs             = \$dir/certs
crl_dir           = \$dir/crl
new_certs_dir     = \$dir/newcerts
database          = \$dir/index.txt
serial            = \$dir/serial
RANDFILE          = \$dir/private/.rand

# The root key and root certificate.
private_key       = \$dir/private/${cert_name}.key
certificate       = \$dir/certs/${cert_name}.crt

# For certificate revocation lists.
crlnumber         = \$dir/crlnumber
crl               = \$dir/crl/revocation.crl
crl_extensions    = crl_ext
default_crl_days  = 30

# SHA-1 is deprecated, so use SHA-2 instead.
default_md        = sha256

name_opt          = ca_default
cert_opt          = ca_default
default_days      = 365
preserve          = no
policy            = policy_$policy

[ policy_strict ]
# The root CA should only sign intermediate certificates that match.
# See the POLICY FORMAT section of 'man ca'.
countryName             = match
stateOrProvinceName     = match
organizationName        = match
organizationalUnitName  = optional
commonName              = supplied
emailAddress            = optional

[ policy_loose ]
# Allow the intermediate CA to sign a more diverse range of certificates.
# See the POLICY FORMAT section of the 'ca' man page.
countryName             = optional
stateOrProvinceName     = optional
localityName            = optional
organizationName        = optional
organizationalUnitName  = optional
commonName              = supplied
emailAddress            = optional

[ req ]
# Options for the 'req' tool ('man req').
default_bits        = 2048
distinguished_name  = req_distinguished_name
string_mask         = utf8only
${extra}

# SHA-1 is deprecated, so use SHA-2 instead.
default_md          = sha256

# Extension to add when the -x509 option is used.
x509_extensions     = v3_ca

[ req_distinguished_name ]
# See <https://en.wikipedia.org/wiki/Certificate_signing_request>.
countryName                     = Country Name (2 letter code)
stateOrProvinceName             = State or Province Name
localityName                    = Locality Name
0.organizationName              = Organization Name
organizationalUnitName          = Organizational Unit Name
commonName                      = Common Name
emailAddress                    = Email Address

# Optionally, specify some defaults.
countryName_default             = SE
stateOrProvinceName_default     = Stockholm
localityName_default            = Stockholm
0.organizationName_default      = ExampleCompany
organizationalUnitName_default  =
emailAddress_default            =

[ v3_ca ]
# Extensions for a typical CA ('man x509v3_config').
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints = critical, CA:true
keyUsage = critical, digitalSignature, cRLSign, keyCertSign

[ v3_intermediate_ca ]
# Extensions for a typical intermediate CA ('man x509v3_config').
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints = critical, CA:true, pathlen:0
keyUsage = critical, digitalSignature, cRLSign, keyCertSign

[ usr_cert ]
# Extensions for client certificates ('man x509v3_config').
basicConstraints = CA:FALSE
nsCertType = client, email
nsComment = "OpenSSL Generated Client Certificate"
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer
keyUsage = critical, nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage = clientAuth, emailProtection

[ server_cert ]
# Extensions for server certificates ('man x509v3_config').
basicConstraints = CA:FALSE
nsCertType = server
nsComment = "OpenSSL Generated Server Certificate"
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer:always
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth, clientAuth
subjectAltName = @alt_names

[ crl_ext ]
# Extension for CRLs ('man x509v3_config').
authorityKeyIdentifier=keyid:always

[ ocsp ]
# Extension for OCSP signing certificates ('man ocsp').
basicConstraints = CA:FALSE
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer
keyUsage = critical, digitalSignature
extendedKeyUsage = critical, OCSPSigning

[ req_ext ]
subjectAltName = @alt_names

[alt_names]
DNS.1 = example.com
DNS.2 = www.example.com
EOF
}

function print_leaf_config() {
dir=$1
fil=$2

cat <<EOF > $dir/$fil
[ req ]
default_bits            = 2048
distinguished_name      = req_distinguished_name
req_extensions          = req_ext
prompt                  = no
 
[ req_distinguished_name ]
C      = SE
ST     = Stockholm
L      = Solna
O      = ExampleCompany
OU     = ExampleUnit 
CN     = example.com
 
[ req_ext ]
subjectAltName          = @alt_names
subjectKeyIdentifier    = hash
 
[alt_names]
DNS.1   = example.com
DNS.2   = www.example.com
email   = email@example.com

[ req ]
default_bits       = 2048
distinguished_name = req_distinguished_name
req_extensions     = req_ext
EOF
}

function print_user_config() {
dir=$1
fil=$2

cat <<EOF > $dir/$fil
[ req ]
default_bits            = 2048
distinguished_name      = req_distinguished_name
 
[ req_distinguished_name ]
C          = Country Name (2 letter code)
C_default  = SE
ST         = State/Province
ST_default = Stockholm
L          = Location
L_default  = Solna
O          = Organization
O_default  = UserDep
OU         = Organization Unit 
OU_default = ExampleUnit 
CN         = Common Name
CN_default = User
 
EOF
}

# Create root folders
for dir in `echo $root_dirs_needed`
do
  if [ ! -d $dir ]; then
    mkdir $dir
  fi
done
# Setup files
for file in `echo $files_needed`
do 
  if [ ! -f $file ]; then
    touch $file
    if [ "index.txt" != $file ]; then
      echo "01" > $file
    fi
  fi
done
# Write config
print_ca_config $(pwd) openssl.cnf strict

# Create intermediate folders
if [ ! -d $inter ]; then
  mkdir $inter
  cd $inter
  for dir in `echo $intermediate_dirs_needed`
  do
    if [ ! -d $dir ]; then
      mkdir $dir
    fi
  done
  # Setup files
  for file in `echo $files_needed`
  do
    if [ ! -f $file ]; then
      touch $file
      if [ "index.txt" != $file ]; then
        echo "1000" > $file
      fi
    fi
  done
  cd ..  
fi
# Write config
print_ca_config "$(pwd)/$inter" openssl.cnf loose

# Create leaf folders
if [ ! -d $leaf ]; then
  mkdir $leaf
  cd $leaf
  for dir in `echo $leaf_dirs_needed`
  do
    if [ ! -d $dir ]; then
      mkdir $dir
    fi
  done
  cd ..
fi
print_leaf_config "$(pwd)/$leaf" www.example.com.cnf

# Create user folders
if [ ! -d $user ]; then
  mkdir $user
  cd $user
  for dir in `echo $user_dirs_needed`
  do
    if [ ! -d $dir ]; then
      mkdir $dir
    fi
  done
  cd ..
fi
print_user_config "$(pwd)/$user" openssl.cnf
