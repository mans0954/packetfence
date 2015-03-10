#!/usr/bin/perl
=head1 NAME

ConfigStore add documentation

=cut

=head1 DESCRIPTION

ConfigStore

=cut

use strict;
use warnings;

use Test::More;                      # last test to print
use Test::NoWarnings;
use File::Slurp qw(read_dir);
use Test::Harness;
use File::Spec::Functions;
BEGIN {
    use lib qw(/usr/local/pf/t /usr/local/pf/lib);
    use PfFilePaths;
}

plan tests => 20;

use_ok("pf::ConfigStore");

my $configStore = new_ok("pf::ConfigStore",[{configFile => './data/test.conf',default_section => 'default'}]);

my @expected_sections = ('default','section1','section1 group 1','section1 group 2','section2');

is_deeply( $configStore->readAllIds, \@expected_sections,"All sections found");

my %section = (param1 => 'value1',param2 => 'value2');

my %default_section = %{$configStore->read("default")};

$configStore->create("section3",\%section);

ok($configStore->hasId("section3"),"Created new section");

is_deeply($configStore->read("section3"),{%section, %default_section},"Section3 Data matches");

$configStore->update("section2",{param3 => 'newvalue'});

ok($configStore->cachedConfig->exists("section2","param3"),"Updated parameter with a value different to the default value");

$configStore->update("section2",{param3 => 'value3'});

ok(!$configStore->cachedConfig->exists("section2","param3"),"Updated parameter with a value equal to the default value");

$configStore->create("section4",{%section, param3 => 'value3', param4 => 'newvalue'});

ok(!$configStore->cachedConfig->exists("section4","param3"),"Created section with a parameter value different than the default value");

ok($configStore->cachedConfig->exists("section4","param4"),"Created section with a parameter value equal to the default value");

$configStore->remove("section4");

ok(!$configStore->hasId("section4"),"Removing a section");

$configStore->copy("section2","section5");

ok($configStore->hasId("section5"),"Copying a section");

is_deeply($configStore->read("section5"), $configStore->read("section2") ,"Copying a section data matches");

my $section5 = $configStore->read("section5");

$configStore->renameItem("section5","section6");

ok(!$configStore->hasId("section5") && $configStore->hasId("section6"),"Renaming a section");

is_deeply($configStore->read("section6"), $section5 ,"Renaming a section data matches");

my @resorted_sections = reverse @{$configStore->readAllIds};

$configStore->sortItems(\@resorted_sections);

is_deeply($configStore->readAllIds, \@resorted_sections ,"Resorting All Sections");

@resorted_sections = @{$configStore->readAllIds};

my $first_section = shift @resorted_sections;

my $last_section = pop @resorted_sections;

@resorted_sections = reverse @resorted_sections;

$configStore->sortItems(\@resorted_sections);

is_deeply($configStore->readAllIds, [$first_section,@resorted_sections,$last_section] ,"Resorting Some Items");


$configStore->update_or_create("section7",{param1 => "value1"});

ok($configStore->hasId("section7") && $configStore->cachedConfig->val("section7","param1") eq "value1","update_or_create create a new section");

$configStore->update_or_create("section7",{param1 => "value1a", param2 => "value2"});

ok($configStore->hasId("section7") && $configStore->cachedConfig->val("section7","param1") eq "value1a","update_or_create updating a value");

ok($configStore->hasId("section7") && $configStore->cachedConfig->val("section7","param2") eq "value2","update_or_create adding a new param to a section");


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
