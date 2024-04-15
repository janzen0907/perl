#!/usr/bin/perl
#
# Demonstrate regex capture groups

# Open the passwd file and assign it to a variable
open(my $PASSWD, "<" , "/etc/passwd") or die "Couldn't open passwd file";

# Loop through the passwd file
while(<$PASSWD>)
{
    chomp;
    my $line = $_;
    # We used regex 101 to create this regex
    if ($line =~ /.+:(4[0-9]+):([0-9]+):/)
    {
        # Accessing the capture groups so we can assign them to variables
        print "UID is $1 GID is $2\n";
    }
}