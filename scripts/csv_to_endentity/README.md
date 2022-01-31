
#  CSV to End Entity

## Description

This is a small utility script that can be used for creating end entities in
EJBCA using a CSV file. Help about script can be obtained by running it without
parameters, or with -h.

Information taken from CSV includes end entity name, CN, and IP address. The IP
address is put into ipaddress subjectAltName. A couple of changes that should be
made prior to running the script should usually include:

- Changing the default values that are passed to bin/ejbca.sh ra addendentity command
  (look for the "Set-up default values for adding the end entity." line).
- If the CSV contains different information that outlined above, the script will
  required some tweaking of CSV line validation, fields read from CSV, and
  arguments passed to bin/ejbca.sh commmand.


## Usage

Run ./csv_to_endentity.sh without parameters for on-line instructions how to call the script


## Changes

- initial commit (copy from EJBCA/bin/extra)

