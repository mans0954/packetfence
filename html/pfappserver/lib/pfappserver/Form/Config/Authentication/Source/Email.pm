package pfappserver::Form::Config::Authentication::Source::Email;

=head1 NAME

pfappserver::Form::Config::Authentication::Source::Email - Web form for email-based self-registration

=head1 DESCRIPTION

Form definition to create or update an Email-verified user source.

=cut

use HTML::FormHandler::Moose;
extends 'pfappserver::Form::Config::Authentication::Source';
with 'pfappserver::Base::Form::Role::Help';

use pf::Authentication::Source::EmailSource;
use pfappserver::Form::Field::Duration;

# Form fields
has_field 'email_activation_timeout' =>
  (
   type => 'Duration',
   label => 'Email Activation Timeout',
   required => 1,
   default => pfappserver::Form::Field::Duration->duration_inflate(pf::Authentication::Source::EmailSource->meta->get_attribute('email_activation_timeout')->default),
   tags => { after_element => \&help,
             help => 'This is the delay given to a guest who registered by email confirmation to log into his email and click the activation link.' },
  );
has_field 'allow_localdomain' =>
  (
   type => 'Toggle',
   checkbox_value => 'yes',
   unchecked_value => 'no',
   label => 'Allow Local Domain',
   default => pf::Authentication::Source::EmailSource->meta->get_attribute('allow_localdomain')->default,
   tags => { after_element => \&help,
             help => 'Accept self-registration with email address from the local domain' },
  );

has_field 'create_local_account' => (
    type => 'Toggle',
    checkbox_value => 'yes',
    unchecked_value => 'no',
    label => 'Create Local Account',
    default => pf::Authentication::Source::EmailSource->meta->get_attribute('create_local_account')->default,
    tags => {
        after_element => \&help,
        help => 'Create a local account on the PacketFence system based on the email address provided.',
    },
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
