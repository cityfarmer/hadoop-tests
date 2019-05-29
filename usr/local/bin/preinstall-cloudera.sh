#!/bin/bash
# set -x

security_config ()
{
    setenforce 0
    sed -i 's/^SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
    systemctl stop firewalld
    systemctl disable firewalld
}
sys_config ()
{
    printf '\n# Hadoop Parameters\nnet.core.netdev_max_backlog=250000\nnet.core.rmem_max=4194304\nnet.core.wmem_max=4194304\nnet.core.rmem_default=4194304\nnet.core.wmem_default=4194304\nnet.core.optmem_max=4194304\nnet.ipv4.tcp_rmem=4096 87380 4194304\nnet.ipv4.tcp_wmem=4096 65536 4194304\nnet.ipv4.tcp_low_latency=1\n' >> /etc/sysctl.conf
    sysctl -p
    yum install -y ntp
    systemctl start ntpd
    systemctl enable ntpd
}

disk_config ()
{
    for x in  a b c d e
    do
      fdisk -l | grep "sd$x"
      if [ $? -eq 1 ]
      then
        echo "Exiting because Disks are not correct!"
        return 1
      fi
    done    
    echo "Creating File Systems"
    printf "\n# HDFS Mounts\n" >> /etc/fstab
    y=1
    for x in b c d e
    do
      yes | mkfs -t ext4 –m 1 –O sparse_super,dir_index,extent,has_journal -T largefile /dev/sd${x}
      printf "/dev/sd${x}                /data${y}                  ext4     noatime,discard 0 0\n" >> /etc/fstab
      mkdir /data${y}
      ((++y))
    done
    mount -a
}

cdh_config ()
{
    tuned-adm off
    tuned-adm list
    systemctl stop tuned
    systemctl disable tuned
    curl -o /etc/default/grub http://10.255.188.206/pub/conf/grub
    grub2-mkconfig -o /boot/grub2/grub.cfg
    printf "vm.swappiness=1\n" >> /etc/sysctl.conf
    printf "vm.vfs_cache_pressure=200\nvm.min_free_kbytes=5242880\n" >> /etc/sysctl.conf
    sysctl -p
}

case "$1" in
  "-p")
    security_config
    sys_config
    ;;
  "-d")
    disk_config
    ;;
  "-c")
    cdh_config
    ;;
  "-a")
    security_config
    sys_config
    disk_config
    cdh_config
    ;;
  *)
    echo "Usage:./preinstall-cloudera.sh { -p (parameters) | -d (disk) | -a (all) }"
    exit 1
    ;;
esac

exit 0
