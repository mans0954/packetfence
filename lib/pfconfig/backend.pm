package pfconfig::backend;

=head1 NAME

pfconfig::backend

=cut

=head1 DESCRIPTION

pfconfig::backend

Abstract class that describes the minimal requirements 
in order to act as a layer 2 cache in pfconfig::manager

The subclasses only have to implement init where they define
the cache attribute of the object.

This cache object will work out of the box if it supports the following methods :
- set($key, $unserialized_object)
- get($key) - has to return the unserialized object
- remove($key)

=cut

use strict;
use warnings;

# abstract class for a backend

sub new {
  my ($class) = @_;
  my $self = bless {}, $class;

  # this needs to be defined in init
  $self->{cache} = undef;

  $self->init();

  return $self;
}

sub init {
  # abstact
}

sub get {
  my ($self, $key) = @_;
  return $self->{cache}->get($key);
} 

sub set {
  my ($self, $key, $value) = @_;
  return $self->{cache}->set($key, $value);
}

sub remove {
  my ($self, $key) = @_;
  return $self->{cache}->remove($key);
}

=back

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2015 Inverse inc.

=head1 LICENSE

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301,
USA.

=cut

1;

# vim: set shiftwidth=4:
# vim: set expandtab:
# vim: set backspace=indent,eol,start:

