
# Author:  Fabien Hochstrasser <fabien.hochstrasser@swisscom.com>
# Date:    2018-04-18

## Description

Nagios check to monitor CMPv2 (HTTP) interface, written in Python.

A CMP certConf request is sent and the pkiConf response is parsed. This does not perform any actual operation on the server
See https://jira.primekey.se/browse/ECA-6871

No good lightweight CMP library was found. So I decided to build the (ASN.1
encoded) certConf message manually, following the grammar described in RFC
4210. The message is sent via a HTTP POST request (RFC 6712). The certConf
message sent is as simple (small) as possible to respect the RFC and make
EJBCA happy (e.g. protectionAlg is optional but EJBCA throws a
NullPointerException if not present).

As a reference, here is a valid CMP certConf message (base64):
MGcwWQIBAqQCMACkEDAOMQwwCgYDVQQDDANBbnmhMDAuBgkqhkiG9n0HQg0wIQQGQUJDREVGMAcGBS
sOAwIaAgIEADAKBggqhkiG9w0CB6IMBAptb25pdG9yaW5nuAowCDAGBAEwAgEA

## Requires
asn1, future, requests

## Usage 
See --help when running the command
