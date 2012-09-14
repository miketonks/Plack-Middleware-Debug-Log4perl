#!/usr/bin/env perl

use strict;
use warnings;

use Plack::Test;
use Plack::Builder;
use Plack::Middleware::Debug::Log4perl;
use HTTP::Request::Common;
use Test::More;

my $content_type = 'text/html'; # ('text/html', 'text/html; charset=utf8',);


note "Content-Type: $content_type";
my $app = sub {
    return [
        200, [ 'Content-Type' => $content_type ],
        ['<body>Hello World</body>']
    ];
};
$app = builder {
    enable 'Debug', panels =>[qw/Response Memory Timer Log4perl/];
	enable 'Log4perl', category => 'plack', conf => '../sample_log4perl.conf';
    $app;
};
test_psgi $app, sub {
    my $cb  = shift;
    my $res = $cb->(GET '/');
    is $res->code, 200, 'response status 200';
    for my $panel (qw/Response Memory Timer Log4perl/) {
        like $res->content,
          qr/<a href="#" title="$panel" class="plDebug${panel}\d+Panel">/,
          "HTML contains $panel panel";
    }
};

done_testing;

