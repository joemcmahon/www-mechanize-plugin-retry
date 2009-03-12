use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'WWW::Mechanize::Plugin::Retry',
    license             => 'perl',
    dist_author         => 'Joe McMahon <mcmahon@yahoo-inc.com>',
    dist_version_from   => 'lib/WWW/Mechanize/Plugin/Retry.pm',
    requires => {
        'Test::More' => 0,
        'Test::Exception' => 0,
        'WWW::Mechanize::Pluggable' => 0,
        'Class::Accessor::Fast' => 0,
    },
    add_to_cleanup      => [ 'WWW-Mechanize-Plugin-Retry-*' ],
);

$builder->create_build_script();
