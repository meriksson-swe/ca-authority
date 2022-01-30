# ca-authority
Scripts to make signing you own certificates easy

I have set ut a collection of scripts and configuration to show how it works when you want to become your own ca authority. I have done this in educational purpose for myself and for you.

## The setup
There are some scripts used for setting up or cleaning the project. The first script `00-setup.sh` is already run in this git repo so there is no need of running it again. The script `clean.sh` can be used to wipe the whole folder structure and all settings-files. This can be used if you played around and want to reset everything. Just run the script followed by `00-setup.sh` and you are good to go again.  

The other scripts are used in the process of creating and signing certificates. They can be divided into three groups:
* 01-02 are used to create your root ca
* 03-05 are used to create a intermediate ca
* 06-08 are used to create a leaf (node) certificate used for server validation.
* A new part for client certficates will be added later on
## How it works
You first of all need a strong key used to sign your own root ca certificate. With this certificate you then sign other certficates. When you then get a certificate signing request (csr), you take a stand on if you trust the information in the signing request and if so, you use your root ca to set a validation mark on their new certificate.  
First let's have a look at this structure.
``` bash
.
├── certs
├── crl
├── crlnumber
├── index.txt
├── newcerts
├── openssl.cnf
├── private
└── serial
```
The folder `certs` contains the root ca file.  
The folder `crl` will contain revoked certifications.
The file `crlnumber` contains the next number in the revoke list.    
The file `index.txt` contains a list of all certificates issued by this ca authority.  
The folder `newcerts` will contain a copy of all certificates issued by this ca authority.  
The file `openssl.cnf` contains configuration.  
The folder `private` contains the key for the ca.  
The file `serial` contains the next number.  

In this guide I have entered some default values in the configuration files so all certficates will belong to the example.com domain.

### Creating root ca
Start by running ´01-create-ca-key.sh´
``` bash
[mattias@localhost test]$ ./01-create-ca-key.sh 
Generating RSA private key, 4096 bit long modulus (2 primes)
...........................................................................++++
............++++
e is 65537 (0x010001)
Enter pass phrase for private/ca.key:
Verifying - Enter pass phrase for private/ca.key:

```
You will be prompted for a password. It must be atleast 4 characters long. Save the password in a safe place.  

Now it's time for generating the root ca certificate.
Kick it off with the script `02-create-root-ca.sh`. It will default to 7300 days expiry, but you can override it by passing a number to the script.  
``` bash
[mattias@localhost test]$ ./02-create-root-ca.sh 
Enter pass phrase for private/ca.key:
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [SE]:
State or Province Name [Stockholm]:
Locality Name [Stockholm]:
Organization Name [ExampleCompany]:
Organizational Unit Name []:  
Common Name []:Example Root CA     
Email Address []:
```
Now we have this structure including cert and key for the ca
``` bash
[mattias@localhost test]$ tree
.
├── 00-setup.sh
├── 01-create-ca-key.sh
├── 02-create-root-ca.sh
├── 03-create-intermediate-key.sh
├── 04-create-intermediate-csr.sh
├── 05-sign-intermediate-csr.sh
├── 06-create-leaf-key.sh
├── 07-create-leaf-csr.sh
├── 08-sign-leaf-csr.sh
├── certs
│   └── ca.crt
├── crl
├── index.txt
├── intermediate
│   ├── certs
│   ├── crl
│   ├── crlnumber
│   ├── csr
│   ├── index.txt
│   ├── newcerts
│   ├── openssl.cnf
│   ├── private
│   └── serial
├── leaf
│   ├── certs
│   ├── csr
│   ├── newcerts
│   ├── private
│   └── www.example.com.cnf
├── newcerts
├── openssl.cnf
├── private
│   └── ca.key
└── serial
```

### Creating a intermediate certificate
First of all we need to create a key for the intermediate certificate. This is done by calling `03-create-intermediate-key.se`  
``` bash
[mattias@localhost test]$ ./03-create-intermediate-key.sh 
Generating RSA private key, 4096 bit long modulus (2 primes)
.........................................................++++
.................................................++++
e is 65537 (0x010001)
Enter pass phrase for intermediate/private/intermediate.key:
Verifying - Enter pass phrase for intermediate/private/intermediate.key:
```
Choose a secure password and store it well.  

Then it's time to create a signing request. Do this by calling the script `04-create-intermediate-csr.sh`
``` bash
[mattias@localhost test]$ ./04-create-intermediate-csr.sh 
Enter pass phrase for intermediate/private/intermediate.key:
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [SE]:
State or Province Name [Stockholm]:
Locality Name [Stockholm]:
Organization Name [ExampleCompany]:
Organizational Unit Name []:
Common Name []:Example Intermediate CA
Email Address []:
```
Finally you will sign the reguest with the ca created earlier. This is done by calling the script `05-signing-intermediate-csr.sh`
``` bash
[mattias@localhost test]$ ./04-create-intermediate-csr.sh 
Enter pass phrase for intermediate/private/intermediate.key:
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [SE]:
State or Province Name [Stockholm]:
Locality Name [Stockholm]:
Organization Name [ExampleCompany]:
Organizational Unit Name []:
Common Name []:Example Intermediate CA
Email Address []:
[mattias@localhost test]$ ./05-sign-intermediate-csr.sh 
Using configuration from openssl.cnf
Enter pass phrase for private/ca.key:
Check that the request matches the signature
Signature ok
Certificate Details:
        Serial Number: 1 (0x1)
        Validity
            Not Before: Jan 30 16:01:49 2022 GMT
            Not After : Jan 28 16:01:49 2032 GMT
        Subject:
            countryName               = SE
            stateOrProvinceName       = Stockholm
            organizationName          = ExampleCompany
            commonName                = Example Intermediate CA
        X509v3 extensions:
            X509v3 Subject Key Identifier: 
                64:E7:A7:BA:66:C2:ED:E7:21:63:16:F0:5A:7D:5D:7C:7E:56:B8:3D
            X509v3 Authority Key Identifier: 
                keyid:6A:24:04:C2:E1:AF:72:CF:AA:BA:CC:33:97:9B:C7:A3:90:6E:32:DD

            X509v3 Basic Constraints: critical
                CA:TRUE, pathlen:0
            X509v3 Key Usage: critical
                Digital Signature, Certificate Sign, CRL Sign
Certificate is to be certified until Jan 28 16:01:49 2032 GMT (3650 days)
Sign the certificate? [y/n]:y


1 out of 1 certificate requests certified, commit? [y/n]y
Write out database with 1 new entries
Data Base Updated

```
Done! Now you have the following folder structure.  
``` bash
[mattias@localhost test]$ tree
.
├── certs
│   └── ca.crt
├── crl
├── index.txt
├── index.txt.attr
├── index.txt.old
├── intermediate
│   ├── certs
│   │   └── intermediate.crt
│   ├── crl
│   ├── crlnumber
│   ├── csr
│   │   └── intermediate.csr
│   ├── index.txt
│   ├── newcerts
│   ├── openssl.cnf
│   ├── private
│   │   └── intermediate.key
│   └── serial
├── leaf
│   ├── certs
│   ├── csr
│   ├── newcerts
│   ├── private
│   └── www.example.com.cnf
├── newcerts
│   └── 01.pem
├── openssl.cnf
├── private
│   └── ca.key
├── serial
└── serial.old

```
### Creating a server certificate (leaf)
Now we have a intermediate certificate to sign server certificates with. The configuration will actually let you use the certificate as a client certification too in a b2b content. This is specified in the server_cert part in the configuration
``` bash
[ server_cert ]
...
extendedKeyUsage = serverAuth, clientAuth
...
```
Again we start off with creating a key for the signing request. We do that by kicking the `06-create-leaf-key.sh`
``` bash
[mattias@localhost test]$ ./06-create-leaf-key.sh 
Generating RSA private key, 2048 bit long modulus (2 primes)
...................+++++
...............................................+++++
e is 65537 (0x010001)
```
Here a shorter key was used and no password was set.  
Time for creating a certification signing request. This is done in `07-create-leaf-csr.sh`. The configuration for this csr is found in leaf/www.example.com.cnf
The script have no output but we can see it was created in the folder structure:
``` bash
[mattias@localhost test]$  tree leaf
leaf
├── certs
├── csr
│   └── www.example.com.csr
├── newcerts
├── private
│   └── www.example.com.key
└── www.example.com.cnf
```
Final step now is to sign this request with the intermediate certificate. This is done with `08-sign-leaf-csr.sh`
``` bash
[mattias@localhost test]$ ./08-sign-leaf-csr.sh 
Using configuration from intermediate/openssl.cnf
Enter pass phrase for /home/mattias/test/intermediate/private/intermediate.key:
Check that the request matches the signature
Signature ok
Certificate Details:
        Serial Number: 4096 (0x1000)
        Validity
            Not Before: Jan 30 16:22:55 2022 GMT
            Not After : Jan 30 16:22:55 2023 GMT
        Subject:
            countryName               = SE
            stateOrProvinceName       = Stockholm
            localityName              = Solna
            organizationName          = ExampleCompany
            organizationalUnitName    = ExampleUnit
            commonName                = example.com
        X509v3 extensions:
            X509v3 Basic Constraints: 
                CA:FALSE
            Netscape Cert Type: 
                SSL Server
            Netscape Comment: 
                OpenSSL Generated Server Certificate
            X509v3 Subject Key Identifier: 
                2D:F0:15:32:CA:FD:A1:DC:9F:61:54:AC:16:96:B8:D8:C2:F9:C3:29
            X509v3 Authority Key Identifier: 
                keyid:64:E7:A7:BA:66:C2:ED:E7:21:63:16:F0:5A:7D:5D:7C:7E:56:B8:3D
                DirName:/C=SE/ST=Stockholm/L=Stockholm/O=ExampleCompany/CN=Example Root CA
                serial:01

            X509v3 Key Usage: critical
                Digital Signature, Key Encipherment
            X509v3 Extended Key Usage: 
                TLS Web Server Authentication, TLS Web Client Authentication
            X509v3 Subject Alternative Name: 
                DNS:example.com, DNS:www.example.com
Certificate is to be certified until Jan 30 16:22:55 2023 GMT (365 days)
Sign the certificate? [y/n]:y


1 out of 1 certificate requests certified, commit? [y/n]y
Write out database with 1 new entries
Data Base Updated

```
The script will also create a chain-certificate in `leaf/certs` that can be used in tls communication to present a full ca-chain to the client.
Now we have the following structure
``` bash
[mattias@localhost test]$ tree
.
├── 00-setup.sh
├── 01-create-ca-key.sh
├── 02-create-root-ca.sh
├── 03-create-intermediate-key.sh
├── 04-create-intermediate-csr.sh
├── 05-sign-intermediate-csr.sh
├── 06-create-leaf-key.sh
├── 07-create-leaf-csr.sh
├── 08-sign-leaf-csr.sh
├── certs
│   └── ca.crt
├── crl
├── index.txt
├── index.txt.attr
├── index.txt.old
├── intermediate
│   ├── certs
│   │   └── intermediate.crt
│   ├── crl
│   ├── crlnumber
│   ├── csr
│   │   └── intermediate.csr
│   ├── index.txt
│   ├── index.txt.attr
│   ├── index.txt.old
│   ├── newcerts
│   │   └── 1000.pem
│   ├── openssl.cnf
│   ├── private
│   │   └── intermediate.key
│   ├── serial
│   └── serial.old
├── leaf
│   ├── certs
│   │   ├── www.example.com.chain.crt
│   │   └── www.example.com.crt
│   ├── csr
│   │   └── www.example.com.csr
│   ├── newcerts
│   ├── private
│   │   └── www.example.com.key
│   └── www.example.com.cnf
├── newcerts
│   └── 01.pem
├── openssl.cnf
├── private
│   └── ca.key
├── serial
└── serial.old

15 directories, 34 files

```

## Summary
Now you have a base for you own ca authority. Hope you find it useful