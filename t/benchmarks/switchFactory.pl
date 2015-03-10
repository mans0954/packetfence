#!/usr/bin/perl
=head1 NAME

switchFactory.pl

=head1 DESCRIPTION

Some performance benchmarks on switchFactory object creation

=cut

use strict;
use warnings;
use diagnostics;

use Benchmark qw(cmpthese);

use lib '/usr/local/pf/lib';

=head1 TESTS

=cut

use pf::SwitchFactory;

=head2 Singleton gain

=cut

cmpthese(1000, {
    getInstance => sub { 
        pf::SwitchFactory->getInstance();
    },
    'new' => sub { 
        pf::SwitchFactory->new();
    }
});

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
