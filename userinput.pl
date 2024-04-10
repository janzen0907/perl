#!/usr/bin/perl
#
# User input in perl

use strict;
use warnings;
use Data::Dumper;

my $name; # $ for scalar variables
my @names = ("Wade", "Bryce"); # @ for arrays or lists

print "What is your name? (press 'q' to quit)\n";
while ($name=<STDIN>)
{


# Gets rid of the new line charecter that is added after printing it
# We could use parenthesis if we wanted but generally not done. Parenthesis should be used when calling a user made function. 

	chomp $name;
	# Double == is used for numeric comparison. Not for strings
	##if ($name == "q"#)
	last if ($name eq "q");
	print "Your name is '$name'\n";

	# Push the variable name into the names array
	push @names, $name;

	print "What is your other name?\n";
}

print "Name: 0: " . $names[0] . "\n";
print @names;
print @names + 0; # This will get the Length of the array 
print Dumper @names;

for (my $i = 0; $i < @names; $i++)
{
	print "Hello, " . $names[$i] . "\n";
}

# This would be another way to start a foreach loop without using the default variable
# foreach my $item (@names)

# Perl will insert the variable name into the print and print each 
# items in the @names array
foreach (@names)
{
	print;
	print "\n";
}


print "GoodBye\n";
