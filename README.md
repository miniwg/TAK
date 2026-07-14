# TAK in the UK

This repository contains miscellaneous files related to using Team Awareness Kit (TAK):

## 1. WallpaperATAK.jpg
This is a wallpaper based on the ATAK splashscreen and includes AJ Johansson's "TAK is the Way"slogan.

## 2. takserver_renewLE24.sh
This is a bash script for use on a TAK server which employs Let's Encrypt public server certificates. It is based on the version 002 script published by the TAK syndicate, with the following updates
- Checks that nothing is running on port 80 to prevent certbot conducting an http challenge validation;
- Checks to see if the script has had a hostname added in the configuration section;
- Uses the password data contained in the CoreConfig.xml file on the TAK server rather than a hardcoded password; and
- logs to the syslog rather than std out.

## 3. taklecr
'TAK Lets Encrypt Check & Renew' (taklecr) is an extension and replacement for takserver_renewLE.  It checks the validity of the LE certificate by querying it on the public port (by default 8446). If the the certificate life is less that the renewal threshold it conducts a certificate renewal.  The script can be triggered by either creating a cronjob or using the systemd service and timer files included in this repo.  
To install: copy the file to the `/usr/local/bin` directory Then:
```
chown root:takadmin /usr/local/bin/taklecr
chmod 710 /usr/local/bin/taklecr
```
Once you have instaled the script, edit the script to change the values in the configuration section to reflect the setup of your TAK server.  If you have a default set up this will only require changing the line:
```
certNameVar="PUT_DOMAIN_HERE"
```
to your domain name - eg: 
```
certNameVar="tak.example.com"
```

## 4. taklecr.service
This is the systemd service file to be used in conjuction with the taklecr script and taklecr timer.  
To install: copy the file to `/etc/systemd/system/` directory Then:
```
chown root: /etc/systemd/system/taklecr.service
chmod 644 /etc/systemd/system/taklecr.service
systemctl daemon-reload
```

## 5. taklecr.timer
This is the systemd timer file to run the taklecr command every day at 04:00. It is used in conjuction with the taklecr script and taklecr service files.  
To install: copy the file to `/etc/systemd/system/` directory Then:
```
chown root: /etc/systemd/system/taklecr.timer
chmod 644 /etc/systemd/system/taklecr.timer
systemctl enable taklecr.timer
```
## 6. Firewalld
This directory contains firewalld service files for the tak server services.  For a basic takserver the tak-base.xml and tak-admin.xml service files are required.  
To install: As root copy the relevant service file to `/etc/firewalld/services` directory.  
After you have copied the file into /etc/firewalld/services it takes about 5 seconds until the new service will be visible in firewalld.  
Typically, the default zone is set to ‘public’, but you can check your active zone by typing:
```
firewall-cmd --get-active-zones
```
Then, add the chosen TAK service to your active zone with the following command:
```
sudo firewall-cmd --zone=public --add-service=tak-base
sudo firewall-cmd --zone=public --add-service=tak-admin
```
By default, the changes you make are temporary and will be lost after a reboot. To make the changes permanent, add the --permanent flag to the commands:
```
sudo firewall-cmd --permanent --zone=public --add-service=tak-base
sudo firewall-cmd --permanent --zone=public --add-service=tak-admin
```
After adding the services, you need to reload FirewallD to apply the changes:
```
sudo firewall-cmd --reload
```
To confirm that the services have been added correctly. To check the services enabled on your zone, use:
```
sudo firewall-cmd --zone=public --list-services
```
You should see `tak-base` and `tak-admin` in the list of allowed services.
## 7. TDAL
This directory contains alternate Coordinate Systems definitions files for use with the ATAK - TDAL plugin.
