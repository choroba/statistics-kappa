package Statistics::Kappa::Cohen;
use 5.026;

our $VERSION = '0.02';

use Moo;
use experimental qw{ signatures };

use List::Util qw{ sum };
use namespace::clean;

has data               => (is => 'ro',   required => 1);
has kappa              => (is => 'lazy', init_arg => undef);
has confusion          => (is => 'lazy', init_arg => undef);
has chance_agreement   => (is => 'lazy', init_arg => undef);
has observed_agreement => (is => 'lazy', init_arg => undef);
has standard_error     => (is => 'lazy', init_arg => undef);

sub categories($self) {
    my %c;
    @c{ map @$_, @{ $self->{data} } } = ();
    return sort keys %c
}

sub confidence_interval($self, $level) {
    [$self->kappa - (1 + $level) * $self->standard_error,
     $self->kappa + (1 + $level) * $self->standard_error]
}

sub _build_standard_error($self) {
    sqrt($self->observed_agreement * (1 - $self->observed_agreement)
         / @{ $self->data } / (1 - $self->chance_agreement) ** 2)
}

sub _build_kappa($self) {
    return ($self->observed_agreement - $self->chance_agreement)
           / (1 - $self->chance_agreement)
}

sub _build_confusion($self) {
    my %c;
    for my $pair (@{ $self->data }) {
        ++$c{ $pair->[0] }{ $pair->[1] }
    }
    return \%c
}

sub _build_observed_agreement($self) {
    return sum(map $self->confusion->{$_}{$_} // 0, keys %{ $self->confusion })
           / @{ $self->data }
}

sub _build_chance_agreement($self) {
    return sum(map { my $c = $_;
                     sum(values %{ $self->confusion->{$c} })
                     * sum(map $self->confusion->{$_}{$c} // 0,
                               $self->categories)
               } $self->categories
    ) / @{ $self->data } ** 2
}

=head1 NAME

Statistics::Kappa::Cohen - Calculate inter-annotator agreement.

=head1 VERSION

Version 0.02

=head1 SYNOPSIS

    use Statistics::Kappa::Cohen;

    my @data = ([1, 1], [1, 0], [1, 0], [0, 0], [1, 1], [0, 1]);
    my $ck = 'Statistics::Kappa::Cohen'->new(data => \@data);
    my $kappa =  $ck->kappa;

=head1 METHODS

=head2 new

The constructor. It takes a named argument C<data> which should contains an
array reference. The elements of the array should be anonymous arrays of two
elements, representing answers by the two raters we are comparing.

=head1 AUTHOR

E. Choroba <choroba@matfyz.cz>

=head1 BUGS

Please report any bugs or feature requests to C<bug-statistics-kappa-cohen at rt.cpan.org>, or through
the web interface at L<https://rt.cpan.org/NoAuth/ReportBug.html?Queue=Statistics-Kappa-Cohen>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Statistics::Kappa::Cohen


You can also look for information at:

=over 4

=item * GitHub issue tracker (report bugs here)

L<https://github.com/choroba/Statistics-Kappa-Cohen/issues>

=item * RT: CPAN's request tracker (or here)

L<https://rt.cpan.org/NoAuth/Bugs.html?Dist=Statistics-Kappa-Cohen>

=item * Search CPAN

L<https://metacpan.org/release/Statistics-Kappa-Cohen>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

This software is Copyright (c) 2026 by E. Choroba <choroba@matfyz.cz>.

This is free software, licensed under:

  The Artistic License 2.0 (GPL Compatible)


=cut

__PACKAGE__
