#/bin/sh
#
# The contents of this file are subject to the terms of the
# Common Development and Distribution License, Version 1.0 only
# (the "License").  You may not use this file except in compliance
# with the License.
#
# You can obtain a copy of the license at
# http://forgerock.org/license/CDDLv1.0.html..
# See the License for the specific language governing permissions
# and limitations under the License.
#
# Copyright 2011 ForgeRock Inc.
 
if [ -d "./config/upgrade" ]
then
  name=`ls -1 ./config/upgrade/schema.ldif.[1-9]*`
  if [ $name ]
  then
    version=`echo $name | cut -d'.' -f 4`
    if [ $version -gt 6311 ] && [ $version -lt 6727 ]
    then
      echo "ldapSyntaxes: ( 1.3.6.1.4.1.26027.1.3.6 DESC 'Collective Conflict Behavior' X-ENUM ( 'real-overrides-virtual' 'virtual-overrides-real' 'merge-real-and-virtual' ) X-SCHEMA-FILE '00-core.ldif' )" >> $name
      instance=`pwd`
      echo "Instance $instance has been patched, you can proceed with the upgrade program now"
      exit 0
    else
      echo "No change required"
      exit 0
    fi
  else
    echo "No schema file matching found."
    exit 1
  fi
else
  echo "Please run this at the root of the OpenDJ or OpenDS instance to upgrade"
  exit 1  
fi
