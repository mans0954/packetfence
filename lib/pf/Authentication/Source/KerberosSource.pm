package pf::Authentication::Source::KerberosSource;

=head1 NAME

pf::Authentication::Source::KerberosSource

=head1 DESCRIPTION

=cut

use pf::config qw($TRUE $FALSE);
use pf::Authentication::constants;
use pf::Authentication::Source;

use Authen::Krb5::Simple;

use Moose;
extends 'pf::Authentication::Source';

has '+type' => ( default => 'Kerberos' );
has 'host' => (isa => 'Str', is => 'rw', required => 1);
has 'realm' => (isa => 'Str', is => 'rw', required => 1);
has 'stripped_user_name' => (isa => 'Str', is => 'rw', default => 'yes');

sub available_attributes {
  my $self = shift;

  my $super_attributes = $self->SUPER::available_attributes;
  my $own_attributes = [ { value => "username", type => $Conditions::SUBSTRING } ];

  return [@$super_attributes, @$own_attributes];
}

=head2 authenticate

=cut

sub authenticate_using_kerberos {

  my ( $self, $username, $password ) = @_;

  my $kerberos = Authen::Krb5::Simple->new( realm => $self->{'realm'} );

  if ($kerberos->authenticate($username, $password)) {
    return ($TRUE, 'Successful authentication using Kerberos.');
  } else {
    return ($FALSE, 'Invalid login or password');
  }

  return ($FALSE, 'Unable to connect to Kerberos server');
}

=head2 match_in_subclass

=cut

sub match_in_subclass {
    my ($self, $params, $rule, $own_conditions, $matching_conditions) = @_;

    $params->{'username'} = $params->{'stripped_user_name'} if (defined($params->{'stripped_user_name'} ) && $params->{'stripped_user_name'} ne '' && isenabled($self->{'stripped_user_name'}));
    return $params->{'username'};
}


=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2013 Inverse inc.

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

# vim: set shiftwidth=4:
# vim: set expandtab:
# vim: set backspace=indent,eol,start:
