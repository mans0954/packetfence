package pfappserver::Model::SoH;

=head1 NAME

pfappserver::Model::SoH - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=cut

use strict;
use warnings;

use Moose;
use namespace::autoclean;

use pf::config;
use pf::error qw(is_error is_success);
use pf::soh;

=head1 METHODS


=head2 exists

This method must be called before any CRUD method.

=cut

sub read {
    my ($self, $filter_id) = @_;

    my $logger = Log::Log4perl::get_logger(__PACKAGE__);
    my ($status, $status_msg) = ($STATUS::OK);

    eval {
        my $soh = pf::soh->new();
        $status_msg = $soh->filter($filter_id);
        unless ($status_msg) {
            $status = $STATUS::NOT_FOUND;
            $status_msg = ["Filter ([_1]) not found.",$filter_id];
        }
    };
    if ($@) {
        $logger->error($@);
        $status = $STATUS::INTERNAL_SERVER_ERROR;
        $status_msg = "Can't fetch filter from the database.";
    }

    return ($status, $status_msg);
}

=head2 filters

=cut

sub filters {
    my ($self) = @_;

    my $logger = Log::Log4perl::get_logger(__PACKAGE__);
    my ($status, $status_msg) = ($STATUS::OK);

    eval {
        my $soh = pf::soh->new();
        $status_msg = $soh->filters();
    };
    if ($@) {
        $logger->error($@);
        $status = $STATUS::INTERNAL_SERVER_ERROR;
        $status_msg = "Can't fetch the filters from the database.";
    }

    return ($status, $status_msg);
}

=head2 update

=cut

sub update {
    my ($self, $configViolationsModel, $filter_ref, $name, $action, $vid, $rules_ref) = @_;

    my $logger = Log::Log4perl::get_logger(__PACKAGE__);
    my ($status, $status_msg) = ($STATUS::OK);

    eval {
        my $soh = pf::soh->new();

        my ($tstatus, $trigger);
        if ($filter_ref->{action} eq 'violation' &&
            ($action ne 'violation' || $filter_ref->{vid} != $vid)) {
            # Remove trigger from previous violation
            ($tstatus, $trigger) = $configViolationsModel->deleteTrigger($filter_ref->{vid}, 'soh::' . $filter_ref->{filter_id});
            $configViolationsModel->commit();
        }
        if ($action eq 'violation' &&
            ($filter_ref->{action} ne 'violation' || $filter_ref->{vid} != $vid)) {
            # Add trigger to new violation
            ($status, $status_msg) = $configViolationsModel->addTrigger($vid, 'soh::' . $filter_ref->{filter_id});
            $configViolationsModel->commit();
        }

        if ($soh->update_filter($filter_ref->{filter_id}, $name, $action, $vid) &&
            $soh->delete_rules($filter_ref->{filter_id})) {
            foreach my $rule (@$rules_ref) {
                $soh->create_rule($filter_ref->{filter_id}, $rule->{class}, $rule->{op}, $rule->{status});
            }
        }
    };
    if ($@) {
        $logger->error($@);
        $status = $STATUS::INTERNAL_SERVER_ERROR;
        $status_msg = "Can't insert filter in the database.";
    }

    return ($status, $status_msg);
}

=head2 delete

=cut

sub delete {
    my ($self, $configViolationsModel, $filter_ref) = @_;

    my $logger = Log::Log4perl::get_logger(__PACKAGE__);
    my ($status, $status_msg) = ($STATUS::OK);

    eval {
        my $soh = pf::soh->new();
        $soh->delete_filter($filter_ref->{filter_id}); # rules will be automatically deleted
        if ($filter_ref->{action} eq 'violation') {
            ($status, $status_msg) = $configViolationsModel->deleteTrigger($filter_ref->{vid}, 'soh::' . $filter_ref->{filter_id});
            $configViolationsModel->commit();
        }
    };
    if ($@) {
        $logger->error($@);
        $status = $STATUS::INTERNAL_SERVER_ERROR;
        $status_msg = "Can't delete filter from the database.";
    }

    return ($status, $status_msg);
}

=head2 create

=cut

sub create {
    my ($self, $configViolationsModel, $name, $action, $vid, $rules_ref) = @_;

    my $logger = Log::Log4perl::get_logger(__PACKAGE__);
    my ($status, $status_msg) = ($STATUS::OK);

    eval {
        my $soh = pf::soh->new();
        my $id = $soh->create_filter($name, $action, $vid);
        if ($id > 0) {
            foreach my $rule (@$rules_ref) {
                $soh->create_rule($id, $rule->{class}, $rule->{op}, $rule->{status});
            }
            if ($action eq 'violation') {
                ($status, $status_msg) = $configViolationsModel->addTrigger($vid, 'soh::' . $id);
                $configViolationsModel->commit();
            }
        }
        else {
            $status = $STATUS::INTERNAL_SERVER_ERROR;
            $status_msg = "Can't insert filter in the database.";
        }
    };
    if ($@) {
        $logger->error($@);
        $status = $STATUS::INTERNAL_SERVER_ERROR;
        $status_msg = "Can't insert filter in the database.";
    }

    return ($status, $status_msg);
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
