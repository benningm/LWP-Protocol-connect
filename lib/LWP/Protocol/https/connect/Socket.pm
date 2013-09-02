package LWP::Protocol::https::connect::Socket;

use strict;
use warnings;

require LWP::Protocol::https;
use IO::Socket::SSL;
our @ISA = qw(IO::Socket::SSL LWP::Protocol::https::Socket);
use LWP::UserAgent;
use HTTP::Request;

sub new {
    my $class = shift;
    my %args = @_;
    my $agent = $args{Agent};
    my ($user, $pass);
    if( defined $args{ProxyUserinfo} ) {
         ($user, $pass) = split(':', URI::Escape::uri_unescape( $args{ProxyUserinfo} ), 2);
    }
    my $proxy_host_port =  $args{'ProxyAddr'}.':'.$args{'ProxyPort'};
    $agent->proxy( http => 'http://'.
	    ( defined $user ? $user.':'.$pass.'@' : '' ).
	    $proxy_host_port.'/' );

    my $host_port = $args{PeerAddr}.":".$args{PeerPort};
    my $host = 'http://'.$host_port;
    my $request = HTTP::Request->new( CONNECT => $host );
    my $response = $agent->request( $request );
    if( $response->is_error ) {
	    die('error while CONNECT thru proxy: '.$response->status_line );
    }
    my $conn = $response->{client_socket};

    delete $args{ProxyAddr};
    delete $args{ProxyPort};
    delete $args{ProxyUserinfo};
    delete $args{Agent};

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

sub http_connect {
    return 1;
}

1;

