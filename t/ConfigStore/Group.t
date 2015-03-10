#!/usr/bin/perl
=head1 NAME

Group

=cut

=head1 DESCRIPTION

Group

=cut

use strict;
use warnings;

use Test::More tests => 16;

use Test::NoWarnings;
BEGIN {
    use lib qw(/usr/local/pf/t /usr/local/pf/lib);
    use PfFilePaths;
}


use_ok("pf::ConfigStore::Group");


my $config = new_ok("pf::ConfigStore",[configFile => './data/group.conf']);

my $group1 = new_ok("pf::ConfigStore::Group",[group => 'group1',configFile => './data/group.conf']);

my $group2 = new_ok("pf::ConfigStore::Group",[group => 'group2',configFile => './data/group.conf']);


is_deeply($group1->readAllIds,[qw(section1 section2)],"group1 sections");

is_deeply($group2->readAllIds,[qw(section1 section2)],"group2 sections");

is_deeply($config->readAllIds,['group1 section1','group1 section2','group2 section1','group2 section2'],"config sections");

$group1->create("section3",{param1=>'value1',param2=>'value2'});

ok($group1->hasId('section3'),"section3 created in group1");

is_deeply($group1->readAllIds,[qw(section1 section2 section3)],"group1 sections after create");

is_deeply($config->readAllIds,['group1 section1','group1 section2','group2 section1','group2 section2','group1 section3'],"config sections");

$group1->sortItems([qw(section3 section2 section1)]);

is_deeply($group1->readAllIds,[qw(section3 section2 section1)],"group1 sections resorted");

is_deeply($config->readAllIds,['group2 section1','group2 section2','group1 section3','group1 section2','group1 section1'],"config after resort sections");

$config->update_or_create("section7",{param1 => "value1"});

ok($config->hasId("section7") && $config->cachedConfig->val("section7","param1") eq "value1","update_or_create create a new section");

$config->update_or_create("section7",{param1 => "value1a", param2 => "value2"});

ok($config->hasId("section7") && $config->cachedConfig->val("section7","param1") eq "value1a","update_or_create updating a value");

ok($config->hasId("section7") && $config->cachedConfig->val("section7","param2") eq "value2","update_or_create adding a new param to a section");



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

1;


