#!/usr/bin/perl
#
# Demostrate switch

use strict;
use warnings;
use Switch;

my $arg = shift;

die "Supply one arg" unless $arg;

switch($arg)
{
    case 'hi'
    {
        print "Hello\n";
    }
    case 'bye' {
        print "Goodbye\n";
    }
    else
    {
        print "Sorry dont understand\n";
    }
}

print "Done\n";




