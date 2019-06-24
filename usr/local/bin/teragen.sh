#!/bin/bash

jobs=$2
logdir='/var/log/hadoop-hdfs'
timestamp=`date`
dstamp=`date '+%Y%m%d'`
libpath='/opt/cloudera/parcels/CDH/lib/hadoop-mapreduce'
selinux=`/usr/sbin/getenforce`
log="$logdir/teragen.log.${selinux}.${dstamp}"

# Cleanup HDFS
cleanup () {
    hadoop fs -rm -r -f -skipTrash $1
    hadoop fs -rm -r -f -skipTrash $2
    hadoop fs -rm -r -f -skipTrash $3
}

info () {
  if [ "$1" = "start" ]
  then
    printf "\n  Starting $3 with $jobs jobs and $2 replication at $timestamp\n\n" >> $log
  elif [ "$1" = "end" ]
  then
    timestamp=`date`
    printf "\n  $3 with $jobs jobs and $2 replication completed at $timestamp\n\n" >> $log
  fi
}

case "$1" in
  "-gen")
    tgout="TS_input_${jobs}_default"
    info "start" "3" "Teragen" 
    { time yarn jar ${libpath}/hadoop-mapreduce-examples.jar teragen -Dmapreduce.job.maps=$jobs 10000000000 $tgout ; } >> $log 2>&1
    info "end" "3" "Teragen"
    ;;
  "-gen1")
    tgout="TS_input_${jobs}_1"
    info "start" "1" "Teragen"
    { time yarn jar ${libpath}/hadoop-mapreduce-examples.jar teragen -Ddfs.replication=1 -Dmapreduce.job.maps=$jobs 10000000000 $tgout ; } >> $log 2>&1
    info "end" "1" "Teragen"
    ;;
  "-sort")
    tgout="TS_input_${jobs}_default"
    info "start" "3" "Terasort"
    output="TS_output_${jobs}_default"
    { time yarn jar ${libpath}/hadoop-mapreduce-examples.jar terasort -Dmapreduce.job.maps=$jobs -Dmapreduce.terasort.output.replication=3 $tgout $output ; } >> $log 2>&1
    info "end" "3" "Terasort"
    ;;
  "-sort1")
    tgout="TS_input_${jobs}_default"
    info "start" "1" "Terasort"
    output="TS_output_${jobs}_1"
    { time yarn jar ${libpath}/hadoop-mapreduce-examples.jar terasort -Dmapreduce.job.maps=$jobs -Dmapreduce.terasort.output.replication=1 $tgout $output ; } >> $log 2>&1
    info "end" "1" "Terasort"
    ;;
  "-val")
    info "start" "3" "Teravalidate"
    tgoutput="TS_input_${jobs}_default"
    tsoutput="TS_output_${jobs}_default"
    tvoutput="TV_output_${jobs}_default"
    { time hadoop jar ${libpath}/hadoop-mapreduce-examples.jar teravalidate $tsoutput $tvoutput ; } >> $log 2>&1
    info "end" "3" "Teravalidate"
    cleanup $tgoutput $tsoutput $tvoutput >> $log 2>&1
    ;;
  "-val1")
    info "start" "1" "Teravalidate"
    tgoutput="TS_input_${jobs}_1"
    tsoutput="TS_output_${jobs}_1"
    tvoutput="TV_output_${jobs}_1"
    { time hadoop jar ${libpath}/hadoop-mapreduce-examples.jar teravalidate $tsoutput $tvoutput ; } >> $log 2>&1
    info "end" "1" "Teravalidate"
    cleanup $tgoutput $tsoutput $tvoutput >> $log 2>&1
    ;;
   *)
    echo "Usage:./teragen.sh { -gen (teragen) | -gen1 (teragen rep1) | -sort (terasort) | -sort1 (terasort rep1) } { <num of jobs> } ex: ./teragen.sh -gen 12 "
    exit 1
    ;;
esac

exit 0
