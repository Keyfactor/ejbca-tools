#!/bin/bash

#Database User.  By default it will get the database user from the properties file
#Software
DBUSER=`cat /opt/ejbca/conf/database.properties | grep database.username | sed 's/database.username=//g'`
#Appliance
#DBUSER=ejbca

#Change this to the database password if using Software or Appliance.  By default it will get the database password from the properties file
#Software
DBPASS=`cat /opt/ejbca/conf/database.properties | grep database.password | sed 's/database.password=//g'`
#Appliance
#DBPASS=`cat /etc/cos/datasource.properties | grep DATABASE_PASSWORD | sed 's/DATABASE_PASSWORD=//g'`

#Database host
#Software
DBHOST=127.0.0.1
#Appliance
#DBHOST=vdb_app

#Database Name
DBNAME=ejbca

# create directory if doesn't alredy exist
if [ ! -d /tmp/cust_certexp ]; then
	mkdir -p /tmp/cust_certexp
fi


echo "\"subjectDN\",\"certSubjectAltName\",\"userSubjectAltName\",\"issuerDN\",\"certProfileName\",\"endEntityProfileName\",\"username\",\"subjectEmail\",\"dateOfExpiry\"" > /tmp/cust_certexp/cert_expire_30days.csv
echo "\"subjectDN\",\"certSubjectAltName\",\"userSubjectAltName\",\"issuerDN\",\"certProfileName\",\"endEntityProfileName\",\"username\",\"subjectEmail\",\"dateOfExpiry\"" > /tmp/cust_certexp/cert_expire_60days.csv
echo "\"subjectDN\",\"certSubjectAltName\",\"userSubjectAltName\",\"issuerDN\",\"certProfileName\",\"endEntityProfileName\",\"username\",\"subjectEmail\",\"dateOfExpiry\"" > /tmp/cust_certexp/cert_expire_90days.csv


# query for certificates expiring in <= 30, 60, or 90 days
query_cert_expiration() {
	local days=$1
	local daysPlusOne=$((days + 1))
	mysql -h $DBHOST -u $DBUSER --password=$DBPASS --raw --skip-column-names -b $DBNAME -e "select cd.subjectDN, COALESCE(cd.subjectAltName,''), COALESCE(ud.subjectAltName,''), cd.issuerDN, COALESCE(cpd.certificateProfileName,''), COALESCE(epd.profileName,'') as endEntityProfileName, ud.username, COALESCE(ud.subjectEmail,''), FROM_UNIXTIME(cd.expireDate/1000) as dateOfExpiry from CertificateData cd left join CertificateProfileData cpd on cd.certificateProfileId = cpd.id left join EndEntityProfileData epd on cd.endEntityProfileId = epd.id left join UserData ud on cd.username = ud.username where FROM_UNIXTIME(cd.expireDate/1000) BETWEEN CURDATE() AND (CURDATE() + INTERVAL $daysPlusOne day) and cd.status = 20 order by cd.issuerDN, cpd.certificateProfileName, epd.profileName, dateOfExpiry"| awk -F\\t '{print "\""$1"\",""\""$2"\",""\""$3"\",""\""$4"\",""\""$5"\",""\""$6"\",""\""$7"\",""\""$8"\",""\""$9"\""}' >> /tmp/cust_certexp/cert_expire_${days}days.csv
}

query_cert_expiration 30
query_cert_expiration 60
query_cert_expiration 90
