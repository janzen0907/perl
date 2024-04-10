#!/usr/bin/perl
#
# Demonstrate reading a file

use strict;
use warnings;

my $lineno = 0;
my $filepath = "./people.txt";
$filepath = $ARGV[0] if @ARGV > 0;
# '<' means we are reading in the file
open(my $PEOPLE_FILE, '<', $filepath) || die "Could not open file";

while (<$PEOPLE_FILE>)
{
    chomp;
    $lineno++;
    print "Line $lineno: $_\n";
}
print "There were $lineno lines in this file.\n"