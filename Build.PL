use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'LWP::Protocol::connect',
    license             => 'perl',
    dist_author         => 'Markus Benning <me@w3r3wolf.de>',
    dist_version_from   => 'lib/LWP/Protocol/connect.pm',
    requires		=> {
        'LWP::Protocol::https' => '>=6.04',
        'URI::http' => 0,
        'Net::HTTP' => 0,
        'IO::Socket::SSL' => 0,
    },
);

$builder->create_build_script();

