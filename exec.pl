#!/usr/bin/perl
#
# Demonstrate the exec command

use strict;
use warnings;

print "We are demonstrating exec\n";
# Replaces the instructions of this program with ./hello.pl
exec("./hello.pl");
# Due to how Exec works this statement would be unreachable as we are not reading in this code anymore.
print("We just exec'd hello.pl\n");
