
#  Custom Certificate Expiration Report v1.0
#  01/15/2019

## Installation

1. Copy the files to cos-ejbca in the specified locations:

	BASH script: 	/etc/custCertExp/cust_certexpire.sh
	cron file:		/etc/cron.d/custCertExp

2. Change permissions on cust_certexpire.sh

	chmod 755 /etc/custCertExp/cust_certexpire.sh

2. Restart the fcron service:

	/etc/init.d/fcron restart

## Usage

The cron job executes the cust_certexpire.sh script daily at 1:30 AM.

The script generates 3 reports in /tmp/cust_certexp (the folder is automatically created if it doesn't exist):

	cert_expire_30days.csv
	cert_expire_60days.csv
	cert_expire_90days.csv

The script copies the files (SSH) to /tmp/cust_certexp on vgw, where it they can be retrieved via SCP.

Each report lists certificates that are expiring in X (30, 60, or 90) days or less.

The reports include a header row, identifying the data in each column.  Reports are sorted by issuerDN, certProfileName, endEntityProfileName, then dateofExpiry
in ascending order.

Headers:

	"subjectDN","certSubjectAltName","userSubjectAltName","issuerDN","certProfileName","endEntityProfileName","username",subjectEmail","dateOfExpiry"


