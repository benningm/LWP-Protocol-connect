package LWP::Protocol::https::connect::Socket;

use strict;
use warnings;

require LWP::Protocol::https;
require Net::HTTP;
use IO::Socket::SSL;
require Net::HTTPS;
our @ISA = qw(IO::Socket::SSL LWP::Protocol::https::Socket);

sub new {
    my $class = shift;
    my %args = @_;
    my $conn = Net::HTTP->new(
        'PeerAddr' => $args{'ProxyAddr'},
        'PeerPort' => $args{'ProxyPort'},
    ) || die $@;

    my $host = $args{PeerAddr}.":".$args{PeerPort};
    $conn->write_request( CONNECT => $host, Host => $host );
    my ($code, $mess, %h) = $conn->read_response_headers;
    if( $code ne "200") {
        die('error while CONNECT thru proxy: '.$code.' '.$mess);
    }

    delete $args{ProxyAddr};
    delete $args{ProxyPort};
    my $ssl = $class->new_from_fd($conn, %args);
    if( ! $ssl ) {
        my $status = 'error while setting up ssl connection';
        if( $@ ) {
                $status .= " (".$@.")";
        }
        die($status);
    }
# HACK: If IO::Socket::SSL uses IO::Socket::INET6, some method fails for IPv4 hosts because socket domain is considered as AF_INET6,
#       like "Bad arg length for Socket6::unpack_sockaddr_in6, length is 16, should be 28".
#       $args{Domain} is not used for setting up socket domain, so force override IO::Socket internal field.
    ${*$ssl}{'io_socket_domain'} = ${*$conn}{'io_socket_domain'} if exists ${*$conn}{'io_socket_domain'};
    $ssl->http_configure( \%args );
    return $ssl;
}

sub http_connect {
    return 1;
}

1;

