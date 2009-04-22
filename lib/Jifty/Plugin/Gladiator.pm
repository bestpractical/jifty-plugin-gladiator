package Jifty::Plugin::Gladiator;
use strict;
use warnings;
use base 'Jifty::Plugin';
use Devel::Gladiator;
use Template::Declare::Tags;
use List::Util 'sum';

our $VERSION = 0.01;

sub count_types {
    # walk the arena, noting the type of each value
    my %types;
    for (@{ Devel::Gladiator::walk_arena() }) {
        ++$types{ ref $_ };
    }

    return \%types;
}

sub inspect_before_request {
    my $self = shift;
    return $self->count_types;
}

sub inspect_after_request {
    my $self = shift;
    my $starting_arena = shift;
    my $current_arena = $self->count_types;

    my %growth;

    # find the difference
    for my $type (keys %$current_arena) {
        my $diff = $current_arena->{$type} - ($starting_arena->{$type} || 0);
        next if $diff == 0;
        $growth{$type} = $diff;
    }

    return \%growth;
}

sub inspect_render_summary {
    my $self   = shift;
    my $growth = shift;

    my $new_values = sum values %$growth;
    my $types      =     keys   %$growth;

    return "$new_values new values in $types types.";
}

sub inspect_render_analysis {
    my $self   = shift;
    my $growth = shift;

    ol {
        for my $type (sort { $growth->{$b} <=> $growth->{$a} } keys %$growth) {
            li { "$type ($growth->{$type})" }
        }
    }
}

1;

__END__

=head1 NAME

Jifty::Plugin::Gladiator - Walk the areas, looking for leaked objects

=head1 DESCRIPTION

This plugin will attempt to output diffs between the current contents
of memory after each request, in order to track leaks.

=head1 USAGE

Add the following to your site_config.yml

 framework:
   Plugins:
     - Gladiator: {}

=head1 SEE ALSO

L<Jifty::Plugin::LeakTracker>

=head1 COPYRIGHT AND LICENSE

Copyright 2007-2009 Best Practical Solutions

This is free software and may be modified and distributed under the same terms as Perl itself.

=cut

