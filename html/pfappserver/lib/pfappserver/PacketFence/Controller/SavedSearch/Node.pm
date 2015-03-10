package pfappserver::PacketFence::Controller::SavedSearch::Node;

=head1 NAME

pfappserver::PacketFence::Controller::SavedSearch::Node add documentation

=cut

=head1 DESCRIPTION

Node

=cut

use strict;
use warnings;
use Moose;
use HTTP::Status qw(:constants is_error is_success);

BEGIN {
    extends 'pfappserver::Base::Controller';
    with 'pfappserver::Base::Controller::Crud';
}

__PACKAGE__->config(
    action => {
        # Reconfigure the object dispatcher from pfappserver::Base::Controller::Crud
        object => { Chained => '/', PathPart => 'savedsearch/node', CaptureArgs => 1 },
        view   => { AdminRole => 'NODES_READ' },
        list   => { AdminRole => 'NODES_READ' },
        create => { AdminRole => 'NODES_READ' },
        update => { AdminRole => 'NODES_READ' },
        remove => { AdminRole => 'NODES_READ' },
    },
    action_args => {
        '*' => { model => 'SavedSearch::Node', form => 'SavedSearch'}
    }
);

=head1 METHODS

=head2 before create

=cut

before 'create' => sub {
    my ( $self, $c ) = @_;
    $c->request->parameters->{pid} = $c->user->id;
};


__PACKAGE__->meta->make_immutable;

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

