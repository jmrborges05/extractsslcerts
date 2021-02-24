#! /bin/bash

function logSeparator {
    echo "************************************************************"
}

#clear old folders entries and zip to avoid missmatch certificates
echo " clear old folders entries and zip to avoid missmatch certificates"
rm -rf ${1} || true
rm -rf ${1}.zip || true

#creating folder for domain
mkdir ${1} || true
cd ${1}
logSeparator

#Export the certificates of each server you want to pin to using:
echo "PEM generated for domain: ${1}"
echo "Get HTTP/1.0" | openssl s_client -servername $1 -showcerts -connect $1:443 > $1.pem
logSeparator

#Convert the .pem files to .der file
echo "converted ${1}.pem to ${1}.der"
openssl x509 -in ${1}.pem -inform PEM -out ${1}.der -outform DER
logSeparator

#create public key file from der file
echo " create public key ${1}.key file from ${1}.der"
openssl x509 -in ${1}.der -inform der -text | openssl x509 -pubkey -noout | openssl rsa -pubin -outform der | openssl dgst -sha256 -binary | openssl enc -base64 > ${1}.key
logSeparator

#extract directly the public key from server
echo " create public key ${1}_from_server.key directly from server"
echo | openssl s_client -connect $1:443 | openssl x509 -pubkey -noout | openssl rsa -pubin -outform der | openssl dgst -sha256 -binary | openssl enc -base64 > ${1}_from_server.key
logSeparator

#compress files into a zip compressed file
echo " generating ${1}.zip"
cd .. || true
zip -r "${1}.zip" "${1}"
echo " files compressed to ${1}.zip"
echo "zip file located at : ${PWD}/${1}.zip"
logSeparator

