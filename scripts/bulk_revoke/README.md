
#  Bulk Revocation v4.0
#  08/16/2019

## Description

This script is used to bulk revoke a number of certificates issued by a specific CA.

## Usage

Edit the revoke.sh script to set the parameters you want to use.

ISSUINGCA is the CA from which you want to revoke certificates.
DBQUERY is the database query to select the serial numbers of the certificate (from ISSUINGCA) that you want to revoke.

In addition to this you need to set the database access variables to access your database. If running on a PrimeKey PKI Appliance the database parameters can be retrieved automatically by the script.

The script assumes the EJBCA CLI is available in /opt/ejbca/bin/ejbca.sh, edit this line if you have EJBCA installed in another location.

## Changes

v4.0: initial commit

