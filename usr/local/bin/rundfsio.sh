#!/bin/bash
logdir='/var/log/hadoop-hdfs'
timestamp=`date`
dstamp=`date '+%Y%m%d'`
selinux=`/usr/sbin/getenforce`
log="$logdir/dfsio.log.${selinux}.${dstamp}"

if [ "$#" -ne 2 ]
then
  echo "Usage:./runalltera.sh { JBOD | RAID0 } { SASHDD | SASSSD }"
  exit 1
fi

/usr/local/bin/dfsio.sh -w 1
sleep 10
/usr/local/bin/dfsio.sh -r 1
/usr/local/bin/dfsio.sh -rr 1
sleep 10
/usr/local/bin/dfsio.sh -w 64
sleep 10
/usr/local/bin/dfsio.sh -r 64
/usr/local/bin/dfsio.sh -rr 64
/usr/local/bin/dfsio.sh -c
sleep 10
/usr/local/bin/dfsio.sh -w 128
sleep 10
/usr/local/bin/dfsio.sh -r 128
/usr/local/bin/dfsio.sh -rr 128
/usr/local/bin/dfsio.sh -c
sleep 10
/usr/local/bin/dfsio.sh -w 256
sleep 10
/usr/local/bin/dfsio.sh -r 256
/usr/local/bin/dfsio.sh -rr 256
/usr/local/bin/dfsio.sh -c
sleep 10
/usr/local/bin/dfsio.sh -w 1024
sleep 10
/usr/local/bin/dfsio.sh -r 1024
/usr/local/bin/dfsio.sh -rr 1024
/usr/local/bin/dfsio.sh -c
sleep 10
/usr/local/bin/dfsio.sh -w 10240
sleep 10
/usr/local/bin/dfsio.sh -r 10240
/usr/local/bin/dfsio.sh -rr 10240
/usr/local/bin/dfsio.sh -c
sleep 10
/usr/local/bin/parser.pl $log $1 $2
exit 0
