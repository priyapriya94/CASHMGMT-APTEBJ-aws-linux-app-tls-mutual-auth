#!/bin/bash

OLD_OPENSSL=`which openssl`

#Download and build Openssl
wget https://www.openssl.org/source/openssl-1.1.1g.tar.gz
tar -zxf openssl-1.1.1g.tar.gz && cd openssl-1.1.1g
./config
make
make test
make install

#Moved Old OpenSSL from executable directory
mv $OLD_OPENSSL /root/

#Linked New Openssl and required lib to their PATH
ln -s /usr/local/lib64/libssl.so.1.1 /usr/lib64/libssl.so.1.1
ln -s /usr/local/lib64/libcrypto.so.1.1 /usr/lib64/libcrypto.so.1.1
ln -s /usr/local/bin/openssl /usr/bin/openssl

#load config /etc/ld
ldconfig

#Check Openssl Version
openssl version
nginx -V

