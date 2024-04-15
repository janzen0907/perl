#!/usr/bin/perl
#
# Demonstrate duplicating file handles

use strict;
use warnings;

# You can duplicate an existing filehandle using open
open(my $OLDOUT, ">&", STDOUT) or die "Can't dupe STDOUT: $!";
open(ANOTHEROUT, ">&", STDOUT) or die "Couldn't dupe STDOUT to ANOTHEROUT: $!";


print "Hello normally.\n";
print $OLDOUT "Hi to old out.\n"; 
print ANOTHEROUT "Hi to another out.\n";
# This would just be a memory address
print "OLDOUT is $OLDOUT\n";

# Perhaps I'm duping STDOUT because I want to redirect STDOUT somewhere else
open(STDOUT, '>', "out.txt") or die "Can't redirect STDOUT: $!";
open(STDERR, ">&STDOUT") or die "Can't redirect STDERR: $!";

print "Goodbye to STDOUT\n";
print $OLDOUT "Goodbye to OLDOUT\n";