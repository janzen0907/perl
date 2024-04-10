#!/usr/bin/perl
#
# Bosses around processes on the system

use strict;
use warnings;
use Data::Dumper;

# $! will give the command that failed
open(my $PS, qq(ps -Ao "%p,%u,%a" |)) or die "Couldn't open pipe from ps. $!\n";

# A hash to store the processes
my %procs;

while (<$PS>)
{
    chomp;
    # create the 3 variables based on spliting on a comma
    (my $pid, my $owner, my $command) = split ",";
    # =~ for a regex
    $pid =~ s/^\s+//;
    $owner =~ s/\s+$//;
    # Next is a continue statement
    next if ($pid eq "PID");
    $procs{$pid}{"owner"} = $owner;
    $procs{$pid}{"command"} = $command;
}

# Pass a reference by using the backslash \ in front of the assosicative array
print Dumper \%procs;

# Loop through the array
foreach my $pid (keys %procs)
{
    # Remember $_ is the default variable
    print qq(Process $pid is owned by $procs{$pid}{"owner"} and is running the command $procs{$pid}{"command"}\n);
}

print "Which process' owner do you want to run the finger command on? (Enter PID) \n";
my $selection = <STDIN>;
chomp $selection;
exists $procs{$selection} or die "You didn't pick a PID we know \n";

# Backticks can be used to run a command (finger)
my $fignerresults = `finger $procs{$selection}{'owner'}`;
print $fignerresults;

# System command returns the exit status of the command
print "Which process do you want to send a kill -15 signal to?\n";
my $selection = <STDIN>;
chomp $selection;
exists $procs{$selection} or die "You didn't pick a PID we know \n";
# 0 is success, anything else is failure, only in Bash. PERL is the oppisite. 
my $systemresult = system("kill -15 $selection &> /dev/null");
print "Result was $systemresult\n";

