#!/usr/bin/env perl

use strict;
use warnings;

use Plack::Test;
use Plack::Builder;
use Plack::Middleware::Debug::Log4perl;
use HTTP::Request::Common;
use Test::More;

my $content_type = 'text/html'; # ('text/html', 'text/html; charset=utf8',);

my $log4perl_conf = <<CONF;
log4perl.rootLogger=TRACE, DebugLog
log4perl.appender.DebugLog=Log::Log4perl::Appender::File
log4perl.appender.DebugLog.filename=log4perl_debug.log
log4perl.appender.DebugLog.mode=append
log4perl.appender.DebugLog.layout=PatternLayout
log4perl.appender.DebugLog.layout.ConversionPattern=[%r] %F %L %c - %m%n
CONF

note "Content-Type: $content_type";
my $app = sub {
	my $logger = Log::Log4perl->get_logger('sample.app');
	$logger->info("Starting Up");
	for my $i (1..10) {
		$logger->debug("Testing .... ($i)");
	}
	$logger->info("All done here - thanks for vising");
    return [
        200, [ 'Content-Type' => $content_type ],
        ['<body>Hello World</body>']
    ];
};
$app = builder {
	enable 'Log4perl', category => 'plack', conf => \$log4perl_conf;
    enable 'Debug', panels =>[qw/Response Memory Timer Log4perl/];
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
    like $res->content, qr{<td>INFO</td>\s+<td>Starting Up</td>\s+<td>sample\.app</td>\s+<td>at t/03_web.t line 26</td>}, "HTML Containts 1st log line";
    like $res->content, qr{<td>DEBUG</td>\s+<td>Testing \.\.\.\. \(1\)</td>\s+<td>sample\.app</td>\s+<td>at t/03_web.t line 28</td>}, "HTML Containts 2nd log line";
    like $res->content, qr{<td>DEBUG</td>\s+<td>Testing \.\.\.\. \(10\)</td>\s+<td>sample\.app</td>\s+<td>at t/03_web.t line 28</td>}, "HTML Containts n-th log line";
    like $res->content, qr{<td>INFO</td>\s+<td>All done here - thanks for vising</td>\s+<td>sample\.app</td>\s+<td>at t/03_web.t line 30</td>}, "HTML Containts last log line";
};

done_testing;

