package pfappserver::Model::OS;

=head1 NAME

pfappserver::Model::OS - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=cut

use strict;
use warnings;

use Moose;
use namespace::autoclean;
#use Readonly;
use Time::localtime;
use Time::Local;

use pf::config;
use pf::error qw(is_error is_success);
use pf::os qw(dhcp_fingerprint_count_searchable dhcp_fingerprint_view_all_searchable);
use pf::util;

=head1 METHODS

=head2 field_names

=cut

sub field_names {
    return [qw(id classid class os fingerprint)];
}

=head2 countAll

=cut

sub countAll {
    my ( $self, %params ) = @_;

    my $logger = Log::Log4perl::get_logger(__PACKAGE__);
    my ($status, $status_msg);

    my $count;
    eval {
        $count = dhcp_fingerprint_count_searchable(%params);
    };
    if ($@) {
        $status_msg = "Can't count fingerprints from database.";
        $logger->error($status_msg);
        return ($STATUS::INTERNAL_SERVER_ERROR, $status_msg);
    }

    return ($STATUS::OK, $count);
}

=head2 search

=cut

sub search {
    my ( $self, %params ) = @_;

    my $logger = Log::Log4perl::get_logger(__PACKAGE__);
    my ($status, $status_msg);

    my @nodes;
    eval {
        @nodes = dhcp_fingerprint_view_all_searchable( %params);
    };
    if ($@) {
        $status_msg = "Can't fetch fingerprints from database.";
        $logger->error($status_msg);
        return ($STATUS::INTERNAL_SERVER_ERROR, $status_msg);
    }

    return ($STATUS::OK, \@nodes);
}


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
