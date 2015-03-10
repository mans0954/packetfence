package pfappserver::Form::Config::Pf;

=head1 NAME

pfappserver::Form::Config::Pf - Web form for pf.conf

=head1 DESCRIPTION

Form definition to create or update a section of pf.conf.

=cut

use HTML::FormHandler::Moose;
extends 'pfappserver::Base::Form';
with 'pfappserver::Base::Form::Role::Help';
use pf::config;

has 'section' => ( is => 'ro' );


=head2 field_list

Dynamically build the field list from the 'section' instance attribute.

=cut

sub field_list {
    my $self = shift;

    my $list = [];
    my $section = $self->section;
    my @section_fields = $cached_pf_default_config->Parameters($section);
    foreach my $name (@section_fields) {
        my $doc_section_name = "$section.$name";
        my $doc_section = $Doc_Config{$doc_section_name};
        my $defaults = $Default_Config{$section};
        $doc_section->{description} =~ s/\n//sg;
        my $field =
          { element_attr => { 'placeholder' => $defaults->{$name} },
            tags => { after_element => \&help, # role method, defined in Base::Form::Role::Help
                      help => $doc_section->{description} },
            id => $name,
            label => $doc_section_name,
          };
        my $type = $doc_section->{type} || "text";
        #skip if hidden
        next if $type eq 'hidden';
        {

            ($type eq "text" && $doc_section->{description} =~ m/comma[-\s](delimite|separate)/si) && do {
                $type = 'text-large';
            };
            $type eq 'text' && do {
                $field->{type} = 'Text';
                last;
            };
            $type eq 'text-large' && do {
                $field->{type} = 'TextArea';
                $field->{element_class} = ['input-xxlarge'];
                last;
            };
            $type eq 'text_with_editable_default' && do {
                $field->{type} = 'Text';
                $field->{default} = $defaults->{$name};
                last;
            };
            $type eq 'list' && do {
                $field->{type} = 'TextArea';
                $field->{element_class} = ['input-xxlarge'];
                # NOTE: line feeds in placeholder attribute are ignored, so we keep the commas and set
                # the value to the default value when no value is defined (see pf::ConfigStore::Pf::cleanupAfterRead)
                # $field->{element_attr}->{placeholder} = join("\n",split( /\s*,\s*/, $field->{element_attr}->{placeholder} ))
                #   if $field->{element_attr}->{placeholder};
                last;
            };
            $type eq 'numeric' && do {
                $field->{type} = 'PosInteger';
                last;
            };
            $type eq 'multi' && do {
                $field->{type} = 'Select';
                $field->{multiple} = 1;
                $field->{element_class} = ['chzn-select', 'input-xxlarge'];
                $field->{element_attr} = {'data-placeholder' => 'Click to add'};
                my @options = map { { value => $_, label => $_ } } @{$doc_section->{options}};
                $field->{options} = \@options;
                last;
            };
            $type eq 'role' && do {
                $field->{type} = 'Select';
                $field->{element_class} = ['chzn-deselect', 'input'];
                $field->{element_attr} = {'data-placeholder' => 'Select a role'};
                my $roles = $self->ctx->model('Roles')->list();
                my @options = ({ value => '', label => ''}, map { { value => $_->{name}, label => $_->{name} } } @$roles);
                $field->{options} = \@options;
                last;
            };
            $type eq 'toggle' && do {
                if ($doc_section->{options}->[0] eq 'enabled' ||
                    $doc_section->{options}->[0] eq 'yes') {
                    $field->{type} = 'Toggle';
                    $field->{checkbox_value} = $doc_section->{options}->[0];
                    $field->{unchecked_value} = $doc_section->{options}->[1];
                }
                else {
                    $field->{type} = 'Select';
                    $field->{element_class} = ['chzn-deselect'];
                    $field->{element_attr} = {'data-placeholder' => 'No selection'};
                    my @options = map { { value => $_, label => $_ } } @{$doc_section->{options}};
                    $field->{options} = \@options;
                }
                last;
            };
            $type eq 'date' && do {
                $field->{type} = 'DatePicker';
                last;
            };
            $type eq 'time' && do {
                $field->{type} = 'Duration';
                last;
            };
            $type eq 'extended_time' && do {
                $field->{type} = 'Text';
                push(@$list, $name => $field);

                # We currently have a single "extended_time" parameter and it's [guests_admin_registration.default_access_duration]
                $name .= "_add";
                $field =
                  {
                   id => $name,
                   label => 'Duration',
                   type => 'ExtendedDuration',
                   no_value => 1,
                   wrapper_class => ['compound-input-btn-group', 'extended-duration', 'well'],
                   tags => { after_element => '<div class="controls"><a href="#" id="addExtendedTime" class="btn btn-info" data-target="#access_duration_choices">' . $self->_localize("Add to Duration Choices") . '</a>' }
                  };
                last;
            };
            $type eq 'email' && do {
                $field->{type} = 'Email';
                last;
            };
        }

        push(@$list, $name => $field);
    }
    return $list;
}

#sub validate {
#    my $self = shift;
#
#    foreach my $section (keys %{$self->value}) {
#        foreach my $field (keys %{$self->value->{$section}}) {
#            my $new_field = $field;
#            $new_field =~ s/::dot::/\./g;
#            $self->value->{$section}->{$new_field}
#              = delete $self->value->{$section}->{$field};
#        }
#    }
#}

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
