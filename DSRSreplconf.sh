#!/bin/bash
#
# The contents of this file are subject to the terms of the
# Common Development and Distribution License, Version 1.0 only
# (the "License").  You may not use this file except in compliance
# with the License.
#
# You can obtain a copy of the license at
# http://forgerock.org/license/CDDLv1.0.html.
# See the License for the specific language governing permissions
# and limitations under the License.
# 
# Copyright 2012 - ForgeRock Inc.
# Author: Ludovic Poitou
if test $# -ne 4
then
  echo "Usage: $0 directory1 directory2 replserver1 replserv2"
  echo "Setup and configure replication between 2 directories, with 2 external replication servers"
  exit 1
fi
WORKING_DIR=`pwd`

H=`uname -n`
echo $H

# Setup Directory Server 1
cd "$1"
./setup -i -n -b "dc=example,dc=com" -d 2000 -h $H -p 1389 --adminConnectorPort 4444 -D "cn=Directory Manager" -w "secret12" -q -Z 1636 --generateSelfSignedCertificate

cd "${WORKING_DIR}"

# Setup Directory Server 2
cd "$2"
./setup -i -n -b "dc=example,dc=com" -a -h $H -p 2389 --adminConnectorPort 5444 -D "cn=Directory Manager" -w "secret12" -q -Z 2636 --generateSelfSignedCertificate

cd "${WORKING_DIR}"

# Setup RS 1
cd "$3"
./setup -i -n -h $H -p 3389 --adminConnectorPort 6444 -D "cn=Directory Manager" -w "secret12" -q -Z 3636 --generateSelfSignedCertificate

cd "${WORKING_DIR}"

# Setup RS 2
cd "$4"
./setup -i -n -h $H -p 4389 --adminConnectorPort 7444 -D "cn=Directory Manager" -w "secret12" -q -Z 4636 --generateSelfSignedCertificate


# First directory with RS1
bin/dsreplication enable --host1 $H --port1 4444 --bindDN1 "cn=directory manager" --bindPassword1 secret12 --noReplicationServer1 --host2 $H --port2 6444 --bindDN2 "cn=directory manager" --bindPassword2 secret12 --replicationPort2 8989 --onlyReplicationServer2 --adminUID admin --adminPassword password --baseDN "dc=example,dc=com" -X -n

# Second directory with RS1
bin/dsreplication enable --host1 $H --port1 5444 --bindDN1 "cn=directory manager" --bindPassword1 secret12 --noReplicationServer1 --host2 $H --port2 6444 --bindDN2 "cn=directory manager" --bindPassword2 secret12 --replicationPort2 8989 --onlyReplicationServer2 --adminUID admin --adminPassword password --baseDN "dc=example,dc=com" -X -n

# First directory with RS2
bin/dsreplication enable --host1 $H --port1 4444 --bindDN1 "cn=directory manager" --bindPassword1 secret12 --noReplicationServer1 --host2 $H --port2 7444 --bindDN2 "cn=directory manager" --bindPassword2 secret12 --replicationPort2 9999 --onlyReplicationServer2 --adminUID admin --adminPassword password --baseDN "dc=example,dc=com" -X -n


# Initialize DS2 with content of DS1
bin/dsreplication initialize --baseDN "dc=example,dc=com" --adminUID admin --adminPassword password --hostSource $H --portSource 4444 --hostDestination $H --portDestination 5444 -X -n


cd "${WORKING_DIR}"
