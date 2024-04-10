#!/usr/bin/perl
#
# Prints out the time


use strict;
use warnings;
# Context, different things will show things in different ways depending on what value we want returned.

my @now_list = localtime();
my $now_scalar = localtime();

print "List: @now_list\n";
print "Scalar: $now_scalar\n";

