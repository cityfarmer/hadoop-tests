#!/bin/bash

timestamp=`date`
dstamp=`date '+%Y%m%d'`
libpath='/opt/cloudera/parcels/CDH/lib/hadoop-mapreduce'
selinux=`/usr/sbin/getenforce`
log="/var/log/hadoop-hdfs/dfsio.log.${selinux}.${dstamp}"


case "$1" in
  "-w")
    printf "\n  Starting DFSIOw with ${2}M file size at $timestamp\n" >> $log
    hadoop jar $libpath/hadoop-mapreduce-client-jobclient-2.6.0-cdh5.16.1-tests.jar TestDFSIO -write -nrFiles 12 -fileSize $2 >> ${log} 2>&1
    printf "\n  End DFSIOw with ${2}M file size at $timestamp\n\n" >> $log
    ;;
  "-r")
    printf "\n  Starting DFSIOr with ${2}M file size at $timestamp\n" >> $log
    hadoop jar $libpath/hadoop-mapreduce-client-jobclient-2.6.0-cdh5.16.1-tests.jar TestDFSIO -read -nrFiles 12 -fileSize $2 >> ${log} 2>&1
    printf "\n  End DFSIOr with ${2}M file size at $timestamp\n\n" >> $log
    ;;
  "-rr")
    printf "\n  Starting DFSIOrr with ${2}M file size at $timestamp\n" >> $log
    hadoop jar $libpath/hadoop-mapreduce-client-jobclient-2.6.0-cdh5.16.1-tests.jar TestDFSIO -read -random -nrFiles 12 -fileSize $2 >> ${log} 2>&1
    printf "\n  End DFSIOrr with ${2}M file size at $timestamp\n\n" >> $log
    ;;
  "-c")
    hadoop jar $libpath/hadoop-mapreduce-client-jobclient-2.6.0-cdh5.16.1-tests.jar TestDFSIO -clean >> ${log} 2>&1
    printf "\n  Cleanup at $timestamp\n\n" >> $log
    ;;
  *)
    echo "Usage:./dfsio.sh { -r | -w } { <filesize> } ex: ./dfsio.sh -w 1000 "
    exit 1
    ;;
esac

exit 0

