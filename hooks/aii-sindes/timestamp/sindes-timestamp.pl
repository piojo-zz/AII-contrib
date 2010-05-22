#!/usr/bin/perl

$|=1;

my $file="/tmp/sindes-timestamp";

while (<STDIN>) {
    open(MYFILE,">$file") or die "Can't open file $file";
    print MYFILE `date`;
    close (MYFILE);
    print "$file\n";
}
