#!/usr/bin/perl
#
# Purpose: Script for managaing LDAP users on a remote system. 
# Author: John Janzen (janzen0907)

# Server Code
sub server {
    my ($socket) = @_;

    # Loop while there is a connection
    while (my $client_socket = $socket->accept())
    {
        # Get the client message
        my $client_message = <$client_socket>;
        chomp($client_message);

        # Check what the message coming from the client is
        if ($client_message eq "userlist")
        {
            # Code here to get a comma seperated list of all the LDAP users on the server
        }

        elsif ($client_message eq "grouplist")
        {
            # Code here to get a comma seperated list of all the LDAP groups on the server
        }

        elsif ($client_message eq "setgroup")
        {
            # Code here to get two arguments - first is the command second is the name of the group to create new users in
            # If this group does not exist, the server should create it. The server should respond to the client 
            # with “set” if the group existed, “created” if the group had to be created, 
            # or “error” if the group did not exist and could not be created.
        }
        
        elsif ($client_message eq "createuser")
        {
            # Code here to get three arguments - first is the command second is the name of the user the client wants to 
            # make, third is the password for the user being created. 
            # The user should use the group previously set with 
            # setgroup, and if setgroup has not been called or was called and failed the user should not be created and 
            # the server should send an “error-nogroup” response to the client. 

            # The new user should have a uid above 5000 and not previously used by any other LDAP user on the server. 
            # You may assume uids and gids in the 5000-6000 range are not being used except by your script. 

            # The newly created user’s home directory should be in /home/[the name of the user’s group]/[the user’s name] 
            # and the server is responsible for appropriately creating the directory using /etc/skel and chowning the 
            # directory to the right uid and gid. If the directory cannot be created, the server should send an “error-nohome” 
            #response to the client

            # If the creation of the LDAP user fails for any other reason, the server should send the client an 
            # “error-other” response

            # How you create the LDAP users is up to you – you can create them as local users first and then convert 
            # them into ldif format before adding them, you can generate the ldifs from a template, or whatever you wish

        }
        else
        {
            # User did not enter a valid command
            print "You did not enter a valid command. Please try again\n";
        }
    }
}

# Client Code