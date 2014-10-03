package pfappserver::Form::Authentication::Source::AD;

=head1 NAME

pfappserver::Form::Authentication::Source::AD - Web form for a AD user source

=head1 DESCRIPTION

Form definition to create or update a Active Directory user source.

=cut

use HTML::FormHandler::Moose;
extends 'pfappserver::Form::Authentication::Source::LDAP';

=head1 COPYRIGHT

Copyright (C) 2012 Inverse inc.

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
