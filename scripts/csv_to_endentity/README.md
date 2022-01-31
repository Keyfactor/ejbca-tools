
#  CSV to End Entity

## Description

This is a small utility script that can be used for creating end entities in
EJBCA using a csv (comma-separated values) file. 

Information taken from the csv file includes end entity name, CN, and IP address. 
The IP address is put into ipaddress subjectAltName. A couple of changes that should be
made prior to running the script usually include:

- Changing the default values that are passed to bin/ejbca.sh ra addendentity command
  (look for the "Set-up default values for adding the end entity" line).
- If the csv file contains different information that outlined above, the script will
  required some tweaking of csv line validation, fields read from csv, and
  arguments passed to bin/ejbca.sh commmand.


## Usage

Help on using the script can be obtained by running it without parameters, or with -h.

## Changes

- initial commit (copy from EJBCA/bin/extra)

