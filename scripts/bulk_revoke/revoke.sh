#!/bin/bash -x

# Change this to be the Issuing CA that you want to revoke certs from
ISSUINGCA="Corporate Issuing CA - G1, O=My Corporation"

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

#Change to get desired query for your database to get relevant data for revocations
DBQUERY="select CONCAT('obase=16; ', serialNumber) as serialNumber from CertificateData where subjectDN like 'unstructuredAddress=10.35.%' or subjectDN like 'unstructuredAddress=10.251.%';"

#Output serial numbers to file
echo "$DBQUERY" | mysql -h $DBHOST -u $DBUSER --password=$DBPASS $DBNAME | grep -v serialNumber | bc > /etc/serial_num.txt

begin_revoke () {
while IFS="" read -r p || [ -n "$p" ]
do
## Change the 6 value in the revokecert command to a different code for permananet revocation.  Status values are:
#Reason integer value: unused(0), keyCompromise(1), cACompromise(2),affiliationChanged(3), superseded(4),
# cessationOfOperation(5),certficateHold(6), removeFromCRL(8), privilegeWithdrawn(9), aACompromise(10).
# Normal reason is 0
   /opt/ejbca/bin/ejbca.sh ra revokecert --dn CN="$ISSUINGCA" -s "$p" -r 6
done < /etc/serial_num.txt
}

for file in /etc/serial_num.txt
do
        if [ "${file}" == "/etc/serial_num.txt" ]
        then
                countSerialNums=$(wc -l < /etc/serial_num.txt)
                echo "Total of ${countSerialNums} Serial Numbers to be revoked in ${file}"
                while true; do
                    read -p "Are you ready to revoke these certificates? Press Y to begin revocation, press N to stop and review the serial #'s. y/n  " yn
                    case $yn in
                        [Yy]* ) begin_revoke;;
                        [Nn]* ) exit=1;;
                        * ) echo "Please answer yes or no.";;
                    esac
        		break
        		done
        	break
        fi
done