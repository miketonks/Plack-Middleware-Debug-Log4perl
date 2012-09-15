
use strict;

package Plack::Middleware::Debug::Log4perl;

use parent qw(Plack::Middleware::Debug::Base);

use Log::Log4perl qw(get_logger :levels);
use Log::Log4perl::Layout;
use Log::Log4perl::Level;

use Data::Dumper;

sub run
{
	my($self, $env, $panel) = @_;

	if(Log::Log4perl->initialized() && !(Log::Log4perl->appender_by_name('plack_debug_panel'))) {
	
	    my $logger = Log::Log4perl->get_logger("");
	
	    # Define a layout
	    my $layout = Log::Log4perl::Layout::PatternLayout->new("%r >> %p >> %m >> %c >> at %F line %L%n");
	
	    # Define an 'in memory' appender
	    my $appender = Log::Log4perl::Appender->new(
	    	"Log::Log4perl::Appender::TestBuffer", 
	    	name => "plack_debug_panel");
	
		$appender->layout($layout);
	
		$logger->add_appender($appender);
		$logger->level($TRACE);
	}

	return sub {
		my $res = shift;

		#$panel->nav_subtitle('Debug');

		my $log = Log::Log4perl->appender_by_name('plack_debug_panel')->buffer();

		if ($log) {

			$log =~ s/ >> /\n/g;
			my $list = [ split '\n', $log ];

			$panel->content( sub { $self->render_list_pairs($list) } );
		}
		else {

			#return $panel->disable;
			$panel->content( 'Log4perl appender not enabled' );
		}
	};
}

my $list_template = __PACKAGE__->build_template(<<'EOTMPL');
<table>
    <thead>
        <tr>
            <th>Time</th>
            <th>Level</th>
            <th>Message</th>
            <th>Source</th>
            <th>Line</th>
        </tr>
    </thead>
    <tbody>
% my $i;
% while (@{$_[0]->{list}}) {
% my($time, $level, $message, $source, $line) = splice(@{$_[0]->{list}}, 0, 5);
            <tr class="<%= ++$i % 2 ? 'plDebugOdd' : 'plDebugEven' %>">
                <td><%= $time %></td>
                <td><%= $level %></td>
                <td><%= $message %></td>
                <td><%= $source %></td>
                <td><%= $line %></td>
            </tr>
% }
    </tbody>
</table>
EOTMPL

sub render_list_pairs {

    my ($self, $list, $sections) = @_;
    if ($sections) {
        $self->render($list_template, { list => $list });
 #       $self->render($list_section_template, { list => $list, sections => $sections });
    }else{
        $self->render($list_template, { list => $list });
    }
}

1;
__END__

=head1 NAME

Plack::Middleware::Debug::Log4perl

Plack debug panel to show detailed Log4perl debug messages.

=head1 SYNOPSIS

  use Plack::Builder;
  use Plack::Middleware::Debug::Log4perl;

  builder {
    enable 'Debug', panels => [qw/Memory Timer Log4perl/];
	enable 'Log4perl', category => 'plack', conf => \$log4perl_conf;
    $app;
  };

=head1 DESCRIPTION

This module provides a plack debug panel that displays the Log4perl messages for your request.

Ideally configure Log4perl using Plack::Midleware::Log4perl, or directly in your .psgi file.  This way we can hook into the root logger at runtime and create the required stealth logger anuomatically.  You can skip the next bit.

For application that configure their own logger, you must create a Log4perl appender using TestBuffer, named 'log4perl_debug_panel'.

In your Log4perl.conf:

  log4perl.rootLogger = TRACE, DebugPanel

  log4perl.appender.DebugPanel              = Log::Log4perl::Appender::TestBuffer
  log4perl.appender.DebugPanel.name         = psgi_debug_panel
  log4perl.appender.DebugPanel.mode         = append
  log4perl.appender.DebugPanel.layout       = PatternLayout
  log4perl.appender.DebugPanel.layout.ConversionPattern = %r >> %p >> %m >> %c >> at %F line %L%n
  log4perl.appender.DebugPanel.Threshold = TRACE

=head1 SEE ALSO

L<Plack::Middleware::Debug>
L<Log::Log4perl>

=cut

