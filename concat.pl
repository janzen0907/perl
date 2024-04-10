#!/usr/bin/perl
#
# Examples of concatenating or adding variables

use strict;
use warnings;

my $number1 = 5;
my $number2 = 7;

my $total = $number1 . $number2;
# Outputs 57
print "Number concated is $total\n";
# Outputs 12
my $totaladd = $number1 + $number2;
print "Number is $totaladd\n";

