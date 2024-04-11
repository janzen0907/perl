#!/usr/bin/perl
#
# Chat server's job is is to listen for a socket connection from a client
# Once it recieves a socket connection from the client, it has to do
# two things at once!
#
# - It needs to accept input from the user terminal, and SEND that input
# over the socket to the client
# - It needs to listen for input from the socket, and write that to
# the terminal

use strict;
use warnings;
use IO::Socket;

(@ARGV == 1) or die "Supply only one argument - the message of the day.";

# Read in the message of the day from the supplied arguments
# This will get the first argument of the command
my $motd = shift; # Use shift on arrays to pull something off the front of the array

# Set up the "ingredients" we need for our socket: A port and an address
my $port = 9999;
my $address = "localhost";

print "SERVER: We are sharing the MOTD: $motd\n";

# Create the socket
# This is OOP, using the Socket and getting the class INET then setting the attributes of it.
my $SOCKET = new IO::Socket::INET(
    LocalPort => $port,
    Proto => 'tcp',
    Listen => 5,
    Reuse => 1
) or die "Couldn't open socket and start listening.\n";

print "SERVER: Socket created, bound, and now listening on port $port.\n";

# Accept connections from the client
# Use the -> notation to call the accept() method from the $SOCKET object
while (my $CLIENT_CONNECTION = $SOCKET->accept())
{
    print "SERVER: Connection recived from client.\n";
    # Get the message from the client
    # The second arg here is how many bytes to read.
    $CLIENT_CONNECTION->recv(my $client_message, 1024);
    print "SERVER: The client said: $client_message";

    print $CLIENT_CONNECTION "MOTD: $motd";
    close $CLIENT_CONNECTION;
    print "SERVER: CLosed connection to client.\n";
}