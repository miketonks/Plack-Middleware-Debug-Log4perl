
use strict;

package Plack::Middleware::Debug::Log4perl;

use parent qw(Plack::Middleware::Debug::Base);

sub run
{
	my($self, $env, $panel) = @_;

	return sub {
		my $res = shift;

		#$panel->nav_subtitle('Debug');

		my $log = $ENV{'plack.middleware.debug.log4perl_debug_log'};

		if ($log) {

			$panel->content( sub { $self->render_list_pairs($log) } );
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

  builder {
    enable 'Debug', panels => [qw/Log4perl/];
    $app;
  };

=head1 DESCRIPTION

This module provides a plack debug panel that displays the Log4perl messages for your request.

Create a Log4perl appender for your application using MemoryBuffer, and assign this to the Plack Environment Variable 'plack.middleware.debug.log4perl_debug_log'.

In your Log4perl.conf:

  log4perl.rootLogger = TRACE, DebugPanel

  log4perl.appender.DebugPanel              = Log::Log4perl::Appender::MemoryBuffer
  log4perl.appender.DebugPanel.name         = psgi_debug_panel
  log4perl.appender.DebugPanel.mode         = append
  log4perl.appender.DebugPanel.layout       = PatternLayout
  log4perl.appender.DebugPanel.layout.ConversionPattern = %r >> %p >> %m >> %c >> at %F line %L%n
  log4perl.appender.DebugPanel.Threshold = TRACE

=head1 SEE ALSO

L<Plack::Middleware::Debug>
L<Log::Log4perl>

=cut

