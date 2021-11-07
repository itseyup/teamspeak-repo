#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")"

#If the bundled openssl is used, the app needs to find out where the CA certs
#are located. This needs to be done with the help of openssl installed on the
#system, before we include "." in the LD_LIBRARY_PATH.

#First test if the bundled libssl is used
#If bundeled libssl is used and SSL_CERT_FILE and SSL_CERT_DIR are not already set. 
if [ -f "./libssl.so.1.0.0" -a -x "$(command -v openssl)" -a -z "${SSL_CERT_FILE+x}" -a -z "${SSL_CERT_DIR+x}" ]
then
  #Set them to sane defaults.

  #Get ssl dir according to system openssl
  OPENSSL_DIR=`openssl version -d | grep -Po '(?<=\").*(?=\")'`

  #Is cert.pem located there?
  if [ -f "${OPENSSL_DIR}/cert.pem" ]
  then
    #Use this file
    export SSL_CERT_FILE=${OPENSSL_DIR}/cert.pem

  #Is certs dir located there?
  elif [ -d "${OPENSSL_DIR}/certs" ]
  then
    #Use this dir
    export SSL_CERT_DIR=${OPENSSL_DIR}/certs
  else
    #An unknown configuration was found. Or openssl/ca certificates were not
    #installed
    echo "Could not find CA certificates location"
    exit 3
  fi
fi

export KDEDIRS=
export KDEDIR=
export QTDIR=.
export QT_PLUGIN_PATH=.
export LD_LIBRARY_PATH=".:$LD_LIBRARY_PATH"

if [ -e ts3client_linux_x86 ]; then
	./ts3client_linux_x86 $@
else
	./ts3client_linux_amd64 $@
fi
