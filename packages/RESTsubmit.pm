package RESTsubmit;

=head1 Package_info

    This module submits a query to the REST server of Ensembl.
    If there is some problem with downloading the requested information, the
    script tries a few more times. If the query is still unsuccessful it throws
    a warning including the queried URL.

=head1 Usage

    my $URL = 'http://grch37.rest.ensembl.org/variation/human/rs1234.json';
    my $response = RESTsubmit($method, $URL, $content);

=head1 Input

    Input of this function is just a valid REST URL.


=over 4

=item $method

It could be either POST or GET

=head1 version

    v.0.1 Last modified: 2015.12.17

=cut


use strict;
use warnings;
use HTTP::Tiny;
use JSON;

sub REST {
    my $URL = $_[0]; # The URL to return
    my $try = 5; # The number the uqery is repeated in case of unsuccessful attempt

    # The second parameter is optional:
    $try = $_[1] if $_[1];

    # Initializing response variable
    my $response;
    my $fail_count = 0;

    until ($response->{success}){

        # Initializing http request:
        my $http = HTTP::Tiny->new();
        $response = $http->get($URL,{headers => { 'Content-type' => 'application/json' }});

        # We exit loop if query was successful:
        last if $response->{success};

        # If query was not successful:
        $fail_count++;
        print STDERR "[Warning] Downloading data from the Ensembl server failed. Trying again.\n";
        sleep(5);

        # If we are failing for the last time:
        if ($fail_count == $try) {
            print STDERR "[Warning] Downloading data from the Ensembl server failed. URL: $URL\n";
            print STDERR "[Warning] Content of returned data:\n", $response->{content},"\n";

            # Exiting at this point from the loop:
            last;
        }

    }

    # Depending on the outcome the caller subroutine will know if the request has failed:
    my $data = "Downloading data from REST failed.";
    $data = decode_json($response->{content}) if $response->{success};

    return ($data);
}

1;