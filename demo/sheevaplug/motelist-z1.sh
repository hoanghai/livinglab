#!/usr/bin/perl -w
use strict;
# $Id: motelist-linux,v 1.4 2006/12/12 18:23:01 vlahan Exp $
# @author Cory Sharp <cory@moteiv.com>
# @author Joe Polastre

my $help = <<'EOF';
usage: motelist [options]

  $Revision: 1.4 $

options:
  -h  display this help
  -c  compact format, not pretty but easier for parsing
  -f  specify the usb-serial file (for smote.cs)
  -k  kernel version: 2.4, 2.6, auto (default)
  -m  method to scan usb: procfs, sysfs, auto (default)
  -dev_prefix  force the device prefix for the serial device
  -usb  display extra usb information
EOF

my %Opt = (
  compact => 0,
  usb => 0,
  method => "auto",
  kernel => "auto",
  dev_prefix => [ "/dev/usb/tts/", "/dev/ttyUSB", "/dev/tts/USB" ],
  usbserial => "sudo cat /proc/tty/driver/usbserial |",
);

while (@ARGV) {
  last unless $ARGV[0] =~ /^-/;
  my $opt = shift @ARGV;
  if( $opt eq "-h" ) { print "$help\n"; exit 0; }
  elsif( $opt eq "-c" ) { $Opt{compact} = 1; }
  elsif( $opt eq "-f" ) { $Opt{usbserial} = shift @ARGV; }
  elsif( $opt eq "-k" ) { $Opt{kernel} = shift @ARGV; }
  elsif( $opt eq "-m" ) { $Opt{method} = shift @ARGV; }
  elsif( $opt eq "-dev_prefix" ) { $Opt{dev_prefix} = shift @ARGV; }
  elsif( $opt eq "-usb" ) { $Opt{usb} = 1; }
  else { print STDERR "$help\nerror, unknown command line option $opt\n"; exit 1; }
}

if( $Opt{kernel} eq "auto" ) {
  $Opt{kernel} = "unknown";
  $Opt{kernel} = $1 if snarf("/proc/version") =~ /\bLinux version (\d+\.\d+)/;
}

if( $Opt{method} eq "auto" ) {
  $Opt{method} =  "sysfs";
}

#my @devs = $Opt{method} eq "procfs" ? scan_procfs() : scan_sysfs();
my @devs = scan_sysfs();
print_motelist( sort { cmp_usbdev($a,$b) } @devs );


#
#  SysFS
#
sub scan_sysfs {

  #  Scan /sys/bus/usb/drivers/usb for FTDI devices
  my @ftdidevs =
    grep { ($_->{UsbVendor}||"") eq "10c4" && ($_->{UsbProduct}||"") eq "ea60" && ($_->{ProductString}||"") eq "Zolertia Z1" }
    map { {
      SysPath => $_,
      UsbVendor => snarf("$_/idVendor",1),
      UsbProduct => snarf("$_/idProduct",1),
      ProductString => snarf("$_/product",1),
    } }
    glob("/sys/bus/usb/drivers/usb/*");

  #  Gather information about each FTDI device
  for my $f (@ftdidevs) {
    my $syspath = $f->{SysPath};

    $f->{InfoManufacturer} = snarf("$syspath/manufacturer",1);
    $f->{InfoProduct} = snarf("$syspath/product",1);
    $f->{InfoSerial} = snarf("$syspath/serial",1);
    $f->{UsbDevNum} = snarf("$syspath/devnum",1);

    my $devstr = readlink($syspath);
    if( $devstr =~ m{([^/]+)/usb(\d+)/.*-([^/]+)$} ) {
      $f->{UsbPath} = "usb-$1-$3";
      $f->{UsbBusNum} = $2;
    }
    ($f->{SysDev} = $syspath) =~ s{^.*/}{};

    my $port = "$syspath/$f->{SysDev}:1.0";
    ($f->{DriverName} = readlink("$port/driver")) =~ s{^.*/}{} if -l "$port/driver";
    ($f->{SerialDevName} = (glob("$port/tty*"),undef)[0]) =~ s{^.*/}{};
    $f->{SerialDevNum} = $1 if $f->{SerialDevName} =~ /(\d+)/;
    $f->{SerialDevName} = getSerialDevName( $f->{SerialDevNum} ) || "  (none)";
  }

  return @ftdidevs;
}

#
#  getSerialDevName
#
#  For each device, force to use dev_prefix if it's not an array.  Otherwise,
#  assume it's a list of candidate prefixes.  Check them and commit to the
#  first one that actually exists.
#
sub getSerialDevName {
  my $devnum = shift;
  my $devname = undef;
  if( defined $devnum ) {
    if( ref($Opt{dev_prefix}) eq "ARRAY" ) {
      $devname = $devnum;
      for my $prefix (@{$Opt{dev_prefix}}) {
        my $file = $prefix . $devnum;
        if( -e $file ) { $devname = $file; last; }
      }
    } else {
      $devname = $Opt{dev_prefix} . $devnum;
    }
  }
  return $devname;
}


#
#  Print motelist
#
sub print_motelist {
  my @devs = @_;

  #  If none were found, quit
  if( @devs == 0 ) {
    print "No devices found.\n";
    return;
  }

  #  Print a header
  if( !$Opt{compact} ) {
    if( $Opt{usb} ) {
      print << "EOF" unless $Opt{compact};
Bus Dev USB Path                 Reference  Device           Description
--- --- ------------------------ ---------- ---------------- -------------------------------------
EOF
    } else {
      print << "EOF" unless $Opt{compact};
Reference  Device           Description
---------- ---------------- ---------------------------------------------
EOF
    }
  }

  #  Print the usb information
  for my $dev (sort { cmp_usbdev($a,$b) } @devs) {
    my $desc = join( " ", $dev->{InfoManufacturer}||"", $dev->{InfoProduct}||"" ) || " (none)";
    my @output = ( $dev->{InfoSerial}||" (none)", $dev->{SerialDevName}, $desc );
    @output = ( $dev->{UsbBusNum}, $dev->{UsbDevNum}, $dev->{UsbPath}, @output ) if $Opt{usb};
    if( $Opt{compact} ) {
      print join(",",@output) . "\n";
    } else {
      printf( ($Opt{usb}?"%3d %3d %-24s ":"")."%-10s %-16s %s\n", @output );
    }
  }
}


#
#  Cmp Usbdev's
#
sub cmp_usbdev {
  my ($a,$b) = @_;
  if( defined $a->{SerialDevNum} ) {
    if( defined $b->{SerialDevNum} ) {
      return $a->{SerialDevNum} <=> $b->{SerialDevNum};
    }
    return -1;
  }
  return 1 if defined $b->{SerialDevNum};
  return ($a->{InfoSerial}||"") cmp ($b->{InfoSerial}||"");
}

#
#  Read a file in
#
sub snarf {
  open my $fh, $_[0] or return undef;
  my $text = do{local $/;<$fh>};
  close $fh;
  $text =~ s/\s+$// if $_[1];
  return $text;
}

