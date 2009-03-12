package WWW::Mechanize::Plugin::Retry;

use warnings;
use strict;
use base qw(Class::Accessor::Fast);
__PACKAGE__->mk_accessors(qw(retry_failed _check_sub 
                             _delays _delay_index));

=head1 NAME

WWW::Mechanize::Plugin::Retry - programatically-controlled fetch retry

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

    use WWW::Mechanize::Pluggable;
    my $foo = WWW::Mechanize::Plugin::Retry->new();
    my $foo->retry_if(\&test_sub, 5, 10, 30, 60);

    # Will run test_sub with the Mech object after the get.
    # If the test_sub returns true, shift off one wait interval
    # from the list, wait that long, and repeat. Give up if
    # unsuccessful every time.

    $foo->get("http://wobbly.site.net");
    if (!$mech->success and $mech->retry_failed) {
      ...
    }

=head1 METHODS

=head2 init

Establish methods in Pluggable's namespace and set up hooks.

=cut

sub init {
  my($class, $pluggable) = @_;
  no strict 'refs';
  local $_;
  eval "*WWW::Mechanize::Pluggable::$_ = \\&$_"
    for qw(retry_if _check_sub _delays _delays_max _delay_index retry_failed);  $pluggable->post_hook('get', sub { posthook(@_) } );
}

=head2 retry_if

Sets up the subroutine to call to see if this is a failure or not.

=cut

sub retry_if {
  my($self, $sub, @times) = @_;

  if (defined $sub) {  
    $self->_check_sub($sub);
    $self->_delays(\@times);
    $self->_delay_index(0);
  }
  else {
    $sub;
  }
}

=head2 posthook

Handles the actual retry, waiting and recursively calling get() as needed.

=cut

sub posthook {
  my($pluggable, $mech, @args) = @_;

  # just leave if we have no retry check, or the check passes.
  if (!defined $pluggable->_check_sub() or 
      !$pluggable->_check_sub->($pluggable)) {
    # Ensure that the delay works next time round, and
    # note that we did not fail retry.
    $pluggable->_delay_index(-1);
    $pluggable->retry_failed(0);
    return;
  }

  # Retry needed (check failed). Are we out of delays?
  my $delay_index = $pluggable->_delay_index;
  if ($delay_index == scalar @{$pluggable->_delays}) {
    # Ran out this time.
    $pluggable->_delay_index(-1);
    $pluggable->retry_failed(1);
  }
  else {
    my $current_delay = $pluggable->_delays->[$delay_index+0];
    $pluggable->_delay_index($pluggable->_delay_index+1);
    sleep $current_delay;
    $pluggable->get(@args);
  }
}

=head1 AUTHOR

Joe McMahon, C<< <mcmahon@yahoo-inc.com> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-www-mechanize-plugin-retry@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=WWW-Mechanize-Plugin-Retry>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2005 Joe McMahon, All Rights Reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of WWW::Mechanize::Plugin::Retry
