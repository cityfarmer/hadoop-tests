#!/bin/bash
logdir='/var/log/hadoop-hdfs'
timestamp=`date`
dstamp=`date '+%Y%m%d'`
selinux=`/usr/sbin/getenforce`
log="$logdir/teragen.log.${selinux}.${dstamp}"

if [ "$#" -ne 2 ]
then
  echo "Usage:./runalltera.sh { JBOD | RAID0 } { SASHDD | SASSSD | SATASSD }"
  exit 1
fi

/usr/local/bin/teragen.sh -gen 12
sleep 20
/usr/local/bin/teragen.sh -sort 12
/usr/local/bin/teragen.sh -val 12
/usr/local/bin/teragen.sh -gen 24
sleep 20
/usr/local/bin/teragen.sh -sort 24
/usr/local/bin/teragen.sh -val 24
#/usr/local/bin/teragen.sh -gen1 12
#sleep 20
#/usr/local/bin/teragen.sh -sort1 12
#/usr/local/bin/teragen.sh -val1 12
#/usr/local/bin/teragen.sh -gen1 24
#sleep 20
#/usr/local/bin/teragen.sh -sort1 24
#/usr/local/bin/teragen.sh -val1 24
sleep 20
/usr/local/bin/parser.pl $log $1 $2

