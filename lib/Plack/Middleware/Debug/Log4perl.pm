
use strict;

package Plack::Middleware::Debug::Log4perl;

#use Time::HiRes;

use parent qw(Plack::Middleware::Debug::Base);

sub run
{
	my($self, $env, $panel) = @_;

	return sub {
		my $res = shift;

		$panel->nav_subtitle('Debug');

		#my $log = $BookBank::Application::z_debug_log;
		my $log = $ENV{'plack.middleware.debug.log4perl_debug_log'};

		if ($log) {

			$panel->content( sub { $self->render_list_pairs($log) } );
		}
		else {

			return $panel->disable;
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
