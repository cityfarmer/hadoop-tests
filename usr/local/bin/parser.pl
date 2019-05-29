#!/usr/bin/perl
#
# Usage:  parser.pl /var/log/hadoop-hdfs/teragen.log.Permissive.20190506 JBOD SASSSD
#use strict;
#use warnings;
use POSIX qw(strftime);

$daccess = $ARGV[1];
$dtyp = $ARGV[2];
$file = $ARGV[0];
$se = (split '/', $file)[-1];
my ($test, $selinux) = (split '\.', $se)[0, 2];
$outputfile = "/root/test";
$date = strftime "%m%d", localtime;

sub tera {
  open(my $fh,'>>',$file);
  print $fh "\n";
  open (FILE, $file);
  while(<FILE>) {
      chomp;
      my $line = $_ if /\bStarting|real\b/;
      if ($line =~ /^  Starting/)
      {
        @str = split /\s+/, $line;
        print $fh "$str[2] 1TB $str[7] $str[4] $daccess 4 $dtyp 3 $selinux $date ";
      } elsif ($line =~ /^real/) {
        @str = split /\s+/, $line;
        @strg = split /m\s*/, $str[1];
        print $fh "$strg[0]\n";
      }
  }
  close (FILE);
  close $fh;
}
sub dfsio {
  open(my $fh,'>>',$file);
  open (FILE, $file);
  while(<FILE>) {
      chomp;
      my $line = $_ if /\bStarting|Throughput|Number of files\b/;
      if ($line =~ /^  Starting/)
      {
        @str = split /\s+/, $line;
      } elsif ($line =~ /Number of files/) {
        $nfiles = (split /\s+/, $line)[7];
      } elsif ($line =~ /Throughput/) {
        $pthr = (split /\s+/, $line)[6];
        $thr = (split '\.', $pthr)[0];
        $hthr = $thr*$nfiles;
        $cthr = $hthr*3;
        print $fh "$str[2] $str[4] $nfiles $daccess $dtyp $thr $hthr $cthr $selinux $date\n";
      }
  }
  close (FILE);
  close $fh;
}

if ($test =~ /teragen/){
  tera();
} elsif ($test =~ /dfsio/){
  dfsio();
}
