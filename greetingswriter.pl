#!/usr/bin/perl
#
# Reads a list of people and writes greeting to them. 

use strict;
use warnings;

die "USAGE: ./greetingswriter.pl <people file> <greetings file>\n" if @ARGV != 2;

my $peoplepath = $ARGV[0];
my $greetingspath = $ARGV[1];

# '<' means we are reading in the file
open(my $PEOPLE_FILE, '<', $peoplepath) || die "Could not open file";
open(my $GREETINGS_FILE, '>', $greetingspath) || die "Could not open file $greetingspath.\n";

while (<$PEOPLE_FILE>)
{
    chomp;
    (my $lastname, my $firstname, my $city, my $address) = split "\t";
    print "Hello $firstname from $city!\n";
    print $GREETINGS_FILE "Hello $firstname from $city!\n";
    
}

close($PEOPLE_FILE);
close($GREETINGS_FILE);
