package LWP::Protocol::connect;

use LWP::Protocol::https::connect;
use LWP::Protocol::https::connect::Socket;

use warnings;
use strict;

# VERSION

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
	ProxyUserinfo => $proxy->userinfo,
	Agent => $self->{ua},
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

=head1 Proxy Authentication

If you pass the authentication within the userinfo string of the proxy url
a Basic authentication header will always be generated and sent to the proxy.

  $ua->proxy('https', 'connect://user:pw@proxyhost.domain:3128');

The more general way is to add the credentials of the proxy to the $ua object.

  $ua->credentials("localhost:3128", "Squid proxy-caching web server", "user", "pw");

In this case the first request to the proxy will fail with a "407 Proxy Auth. Required".
This will cause LWP::UserAgent to choose the right LWP::Authen::<method> module to
add the authentication and retry.

=head1 DESCRIPTION

The LWP::Protocol::connect module provides support for using https over
a proxy via the HTTP/CONNECT method.

=head1 SEE ALSO

L<IO::Socket::SSL>, L<LWP::Protocol::https>

=head1 COPYRIGHT

Copyright 2013 Markus Benning <me@w3r3wolf.de>

This library is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

