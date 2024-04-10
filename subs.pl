#!/usr/bin/perl
#
# Demonstrate subroutines in perl

use strict;
use warnings;

say_hello();

my $input;

print "What do you say in return?\n";

while (<STDIN>)
{
	chomp;
	# Die is a way to end a program, this will provide text with it
	die "You said bye!" if check_bye($_);

	print "You said $_.\n";
}

print "Done talking.\n";

sub check_bye {
	my ($arg1) = @_;
	print "Passed in:";
	# Array of the variables passed in
	#print @_;
	print "$arg1\n";
	# 0 is false in perl
	return 0 if ($arg1 ne "bye");
	return 1;
}

sub say_hello {
	print "Hello.\n";
}

