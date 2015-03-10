package pfappserver::Form::Field::MACAddress;

=head1 NAME

pfappserver::Form::Field::MACAddress - MAC address input field

=head1 DESCRIPTION

This field extends the default Text field and checks if the input
value is a MAC address.

=cut

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Field::Text';

use pf::util;
use namespace::autoclean;

our $class_messages = {
    'mac' => 'Value must be a MAC address',
};

sub get_class_messages {
    my $self = shift;
    return {
       %{ $self->next::method },
       %$class_messages,
    }
}

apply
  (
   [
    {
     check => sub {
         my ( $value, $field ) = @_;
         return valid_mac( $value );
     },
     message => sub {
         my ( $value, $field ) = @_;
         return $field->get_message('mac');
     },
    },
    {
     transform => sub {
         my ($value, $field ) = @_;
         return clean_mac($value);
     },
     message => sub {
         my ( $value, $field ) = @_;
         return $field->get_message('mac');
     },
    }
   ]
  );

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

__PACKAGE__->meta->make_immutable;
1;
