package LWP::Protocol::https::connect::Socket;

use strict;
use warnings;

# VERSION

require LWP::Protocol::https;
use IO::Socket::SSL;
use LWP::Protocol::connect::Socket::Base;
our @ISA = qw(LWP::Protocol::connect::Socket::Base IO::Socket::SSL LWP::Protocol::https::Socket);

sub new {
    my $class = shift;
    my %args = @_;
    my $conn = $class->_proxy_connect( \%args );

    my $ssl = $class->new_from_fd($conn, %args);
    if( ! $ssl ) {
        my $status = 'error while setting up ssl connection';
        if( $@ ) {
                $status .= " (".$@.")";
        }
        die($status);
    }
    $ssl->http_configure( \%args );
    return $ssl;
}

1;

