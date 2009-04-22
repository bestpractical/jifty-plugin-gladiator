package Jifty::Plugin::Gladiator;
use strict;
use warnings;
use base 'Jifty::Plugin';
use Devel::Gladiator;
use Template::Declare::Tags;

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

    my $new_values = 0;
    my $new_types  = 0;

    my %types;

    # find the difference
    for my $type (keys %$current_arena) {
        my $diff = $current_arena->{$type} - $starting_arena->{$type};

        if ($diff != 0) {
            $new_values += $diff;
            ++$new_types;
        }

        $types{$type} = {
            all => $current_arena->{$type},
            new => $diff,
        }
    }

    return {
        new_values => $new_values,
        new_types  => $new_types,
        types      => \%types,
    };
}

sub inspect_render_summary {
    my $self   = shift;
    my $growth = shift;

    return "$growth->{new_values} new values in $growth->{new_types} types";
}

sub inspect_render_analysis {
    my $self   = shift;
    my $growth = shift;
    my $types  = $growth->{types};

    ol {
        for my $type (sort { $types->{$b} <=> $types->{$a} } keys %$types) {
            li { "$type ($types->{$type})" }
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

