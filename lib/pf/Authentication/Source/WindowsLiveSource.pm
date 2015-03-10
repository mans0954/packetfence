package pf::Authentication::Source::WindowsLiveSource;

=head1 NAME

pf::Authentication::Source::WindowsLiveSource

=head1 DESCRIPTION

=cut

use pf::person;
use Moose;
extends 'pf::Authentication::Source::OAuthSource';

has '+type' => (default => 'WindowsLive');
has '+class' => (default => 'external');
has '+unique' => (default => 1);
has 'client_id' => (isa => 'Str', is => 'rw', required => 1);
has 'client_secret' => (isa => 'Str', is => 'rw', required => 1);
has 'site' => (isa => 'Str', is => 'rw', default => 'https://login.live.com');
has 'authorize_path' => (isa => 'Str', is => 'rw', default => '/oauth20_authorize.srf');
has 'access_token_path' => (isa => 'Str', is => 'rw', default => '/oauth20_token.srf');
has 'access_token_param' => (isa => 'Str', is => 'rw', default => 'oauth_token');
has 'scope' => (isa => 'Str', is => 'rw', default => 'wl.basic,wl.emails');
has 'protected_resource_url' => (isa => 'Str', is => 'rw', default => 'https://apis.live.net/v5.0/me');
has 'redirect_url' => (isa => 'Str', is => 'rw', required => 1, default => 'https://<hostname>/oauth2/windowslive');
has 'domains' => (isa => 'Str', is => 'rw', required => 1, default => 'login.live.com,auth.gfx.ms,account.live.com');
has 'create_local_account' => (isa => 'Str', is => 'rw', default => 'no');

=head2 lookup_from_provider_info

Lookup the person information from the authentication hash received during the OAuth process

=cut

sub lookup_from_provider_info {
    my ( $self, $pid, $info ) = @_;
    person_modify( $pid, firstname => $info->{first_name}, lastname => $info->{last_name} );
}

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

__PACKAGE__->meta->make_immutable;
1;

# vim: set shiftwidth=4:
# vim: set expandtab:
# vim: set backspace=indent,eol,start:
