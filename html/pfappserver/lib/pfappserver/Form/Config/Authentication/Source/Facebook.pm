package pfappserver::Form::Config::Authentication::Source::Facebook;

=head1 NAME

pfappserver::Form::Config::Authentication::Source::Facebook - Web form for a Facebook user source

=head1 DESCRIPTION

Form definition to create or update a Facebook user source.

=cut

use HTML::FormHandler::Moose;
extends 'pfappserver::Form::Config::Authentication::Source';
with 'pfappserver::Base::Form::Role::Help';

use pf::Authentication::Source::FacebookSource;

# Form fields
has_field 'client_id' =>
  (
   type => 'Text',
   label => 'App ID',
   required => 1,
  );
has_field 'client_secret' =>
  (
   type => 'Text',
   label => 'App Secret',
   required => 1,
  );
has_field 'site' =>
  (
   type => 'Text',
   label => 'Graph API URL',
   required => 1,
   default => pf::Authentication::Source::FacebookSource->meta->get_attribute('site')->default,
   element_class => ['input-xlarge'],
  );
has_field 'access_token_path' =>
  (
   type => 'Text',
   label => 'Graph API Token Path',
   required => 1,
   default => pf::Authentication::Source::FacebookSource->meta->get_attribute('access_token_path')->default,
  );
has_field 'access_token_param' =>
  (
   type => 'Text',
   label => 'Access Token Parameter',
   required => 1,
   default => pf::Authentication::Source::FacebookSource->meta->get_attribute('access_token_param')->default,
  );
has_field 'scope' =>
  (
   type => 'Text',
   label => 'Scope',
   required => 1,
   default => pf::Authentication::Source::FacebookSource->meta->get_attribute('scope')->default,
   tags => { after_element => \&help,
             help => 'The permissions the application requests.' },
  );
has_field 'protected_resource_url' =>
  (
   type => 'Text',
   label => 'Graph API URL of logged user',
   required => 1,
   default => pf::Authentication::Source::FacebookSource->meta->get_attribute('protected_resource_url')->default,
   element_class => ['input-xlarge'],
  );
has_field 'redirect_url' =>
  (
   type => 'Text',
   label => 'Portal URL',
   required => 1,
   default => pf::Authentication::Source::FacebookSource->meta->get_attribute('redirect_url')->default,
   element_attr => {'placeholder' => pf::Authentication::Source::FacebookSource->meta->get_attribute('redirect_url')->default},
   element_class => ['input-xlarge'],
   tags => { after_element => \&help,
             help => 'The hostname must be the one of your captive portal.' },
  );

has_field 'domains' =>
  (
   type => 'Text',
   label => 'Authorized domains',
   required => 1,
   default => pf::Authentication::Source::FacebookSource->meta->get_attribute('domains')->default,
   element_attr => {'placeholder' => pf::Authentication::Source::FacebookSource->meta->get_attribute('domains')->default},
   element_class => ['input-xlarge'],
   tags => { after_element => \&help,
             help => 'Comma separated list of domains that will be resolve with the correct IP addresses.' },
  );

has_field 'create_local_account' => (
    type => 'Toggle',
    checkbox_value => 'yes',
    unchecked_value => 'no',
    label => 'Create Local Account',
    default => pf::Authentication::Source::FacebookSource->meta->get_attribute('create_local_account')->default,
    tags => {
        after_element => \&help,
        help => 'Create a local account on the PacketFence system based on the account email address provided.',
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
