#!/bin/bash

##Mark Halliday Mini workgroups ltd - v002.4-1 - 02 August 2025
##Changed to read passwords from CoreConfig for Ubuntu/Rocky compatibility
##Based on:
##Ryan Schilder - v002 - June 12 2023
##This script will create LetsEncrypt certificates for the takserver

## REQUIREMENTS
##You MUST have a public IP address. eg ipv4: 123.456.789.012 or ipv6: 1234:5678:90AB:CDEF:1234:5678:90AB:CDEF
##You MUST have a domain registered with a DNS server. eg example.com
##You MUST have already created an 'A' (ipv4) or 'AAA' (ipv6) record for the takserver on the DNS server, 
##              and pointed it at your public IP address. eg takserver1

##If you don't have all of this, DO NOT RUN THIS SCRIPT. It will fail.

## CONFIGURATION
##Edit these values to reflect your actual setup BEFORE running.
##Edit this line, to enter the Fully Qualified Domain Name of your takserver. eg "takserver1.example.com"
certNameVar="PUT_DOMAIN_HERE"
##Edit this line if you are using a non default name for the Let's Encrypt Java keystore in your CoreConfig file
javaKeystoreVar="takserver-le"

## Edit this line if you have not installed TAK in the default /opt/tak directory
TAK_LOCATION=/opt/tak

##TAK config file location
##Set path for CoreConfig.xml file
TAK_CC=$TAK_LOCATION/CoreConfig.xml

##DO NOT EDIT BELOW THIS LINE
## SCRIPT

##Check certNameVar is configured to domain name
case $certNameVar in
(PUT_DOMAIN_HERE)
   ## log configuration error to syslog and std err
   sudo logger -s -p err "takserver_renewLECerts - FQDN not configured replace PUT_DOMAIN_HERE"
   ;;
(*)
   ## Check that port 80 is clear for certbot validation
   if 2> /dev/null > /dev/tcp/$CertNameVar/80
   then
       ## Log port 80 in use to syslog and std err
       sudo logger -s -p err "takserver_renewLECerts - $CertNameVar Port 80 in use and unavailable for cerbot"
   else
       ## Conduct a certificate renewal dry run to verify permissions and path
       sudo certbot renew --force-renewal

       ## Get the TAK truststore password from CoreConfig.xml
       TAKPASS=$(xmllint --xpath "string(//*[local-name()='tls']/@truststorePass)" $TAK_CC 2>/dev/null | xargs || true)

       ## Create our PKCS12 certificate from our signed certificate and private key
       sudo openssl pkcs12 -export -in /etc/letsencrypt/live/$certNameVar/fullchain.pem -inkey /etc/letsencrypt/live/$certNameVar/privkey.pem -out $javaKeystoreVar.p12 -name $certNameVar -password pass:$TAKPASS

       ## Uncomment line below to view our PKCS12 content
       #sudo openssl pkcs12 -info -in $javaKeystoreVar.p12

       ## Create our Java Keystore from our PKCS12 certificate
       sudo keytool -importkeystore -srcstorepass $TAKPASS -deststorepass $TAKPASS -destkeystore $javaKeystoreVar.jks -srckeystore $javaKeystoreVar.p12 -srcstoretype pkcs12

       ## remove the old jks and p12 files
       sudo rm $TAK_LOCATION/certs/files/$javaKeystoreVar.jks
       sudo rm $TAK_LOCATION/certs/files/$javaKeystoreVar.p12

       ## Move the certificate to the TAK certificate directory
       sudo mv $javaKeystoreVar.jks $TAK_LOCATION/certs/files/
       sudo mv $javaKeystoreVar.p12 $TAK_LOCATION/certs/files/

       ## Restore tak ownership permissions for the certs/files directory
       sudo chown tak: $TAK_LOCATION/certs/files/$javaKeystoreVar.*

       ## Restart takserver
       sudo systemctl restart takserver

       ## Log success to syslog
       sudo logger -p info "takserver_renewLECerts - complete - wait a minute before checking"
   fi 
   ;;
esac
