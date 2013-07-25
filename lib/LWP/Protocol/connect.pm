package LWP::Protocol::https::connect;
our $VERSION = '6.00';
require LWP::Protocol::https;
our @ISA = qw(LWP::Protocol::https);
LWP::Protocol::implementor('https::connect' => 'LWP::Protocol::https::connect');

sub new {
    my $self = shift->SUPER::new(@_);
    $self->{scheme} =~ s/::connect$//;
    $self;
}

sub _extra_sock_opts {
    my $self = shift;
    my($host, $port) = @_;
    my @extra_sock_opts = $self->SUPER::_extra_sock_opts(@_);
    return (@extra_sock_opts, @{$self->{proxy_connect_opts}});
}

package LWP::Protocol::https::connect::Socket;
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
    return $ssl;
}

sub http_connect {
    return 1;
}

package LWP::Protocol::connect;
require LWP::Protocol;
our @ISA = qw(LWP::Protocol);

sub request {
    my($self, $request, $proxy, $arg, $size, $timeout) = @_;
    my $url = $request->uri;
    my $scheme = $url->scheme;

    if(!defined $proxy) {
	    return HTTP::Response->new( &HTTP::Status::RC_BAD_REQUEST,
		    'HTTP/CONNECT method protocol schema can only be used with a proxy!');
    }

    my $protocol = LWP::Protocol::create("$scheme\::connect", $self->{ua});
    $protocol->{proxy_connect_opts} = [
    	ProxyAddr => $proxy->host,
	ProxyPort => $proxy->port,
    ];

    $protocol->request($request, undef, $arg, $size, $timeout);
}

1;

__END__

=head1 NAME

LWP::Protocol::connect - Provides HTTP/CONNECT proxy support for LWP::UserAgent

=head1 SYNOPSIS

  use LWP::UserAgent;

  $ua = LWP::UserAgent->new(); 
  $ua->proxy('https', 'connect://proxyhost.domain:3128/');

  $ua->get('https://www.somesslsite.com');

=head1 DESCRIPTION

The LWP::Protocol::connect module provides support for using https over
a proxy via the HTTP/CONNECT method.

=head1 SEE ALSO

L<IO::Socket::SSL>, L<LWP::Protocol::https>

=head1 COPYRIGHT

Copyright 2013 Markus Benning <me@w3r3wolf.de>

This library is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

