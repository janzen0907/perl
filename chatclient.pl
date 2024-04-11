#!/usr/bin/perl
#
# Chat client's job is to make a connection to server specified by the user
# from the command line argumets.
#
# If it is able to make that connection, it has to do two things simultaniously:
#
# - It needs to listen to the socket connection, and print out anything it recives
# on the terminal
# - It needs to accept user input from the terminal, and send everything the user
# inputs over the socket connection

use strict;
use warnings;
use IO::Socket;

(@ARGV == 2) or die "Supply only two args - the address and the port of the server";

my $server_address = shift;
my $server_port = shift;

my $SOCKET = new IO::Socket::INET(
    PeerAddr => $server_address,
    PeerPort => $server_port,
    Proto => 'tcp'
) or die "Could not connect to the server";

print "CLIENT: Connect to $server_address:$server_port\n";

# Here is where we can send messages the server
$SOCKET->send("Here we need to add the users message");

while (<$SOCKET>)
{
    print "CLIENT: Recived this message from the server: $_\n";
}

print "CLIENT: Lost connection to server";
close $SOCKET or die "Couldn't close sockets.\n";

