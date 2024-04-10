#!/usr/bin/perl
#
# Take two arguments both ints

use strict;
use warnings;

print "Enter a Low and a high integer\n";

open(my $psswd, '<', '/etc/passwd') or die "Cannot open /etc/passwd\n"; 

my $numberOne = $ARGV[0];
my $numberTwo = $ARGV[1];

while (my $line = <$psswd>)
{
    chomp $line;
    (my $username, my $uid, my $homedir) = split(":", $line);

    if ($uid >= $numberOne and $uid <= $numberTwo)
    {
        print ("$username ($uid) has a homedir of $homedir\n");
    }
}