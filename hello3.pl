#!/usr/bin/perl
#

use strict;
use warnings;


# Check if exactly 3 arguments are provided
die "Usage: $0 <arg1> <arg2> <arg3>\n" unless @ARGV == 3;

# Extract arguments from @ARGV
my ($arg1, $arg2, $arg3) = @ARGV;

# Loop through the arguments and print a greeting
foreach my $arg ($arg1, $arg2, $arg3) 
{
    print "Hello, $arg!\n";
}

