#!/usr/bin/perl -w

use strict;
use warnings;
use diagnostics;


# pf core libs
use lib qw(/usr/local/pf/lib /usr/local/pf/html/pfappserver/lib);
BEGIN {
    use lib qw(/usr/local/pf/t);
    use PfFilePaths;
}

BEGIN {

    use File::Slurp qw(read_dir);
    use File::Spec::Functions;
    sub _readDirRecursive {
        my ($root_path,@subdir) = @_;
        my @files;
        foreach my $entry (read_dir($root_path)) {
            my $full_path = catfile($root_path,$entry);
            if (-d $full_path) {
                push @files, map {catfile($entry,$_) } _readDirRecursive($full_path);
            }
            elsif ($entry !~ m/^\./) {
                push @files, $entry;
            }
        }
        return @files;
    }

    use Test::More;
    use Test::NoWarnings;
    our %exclude;
    @exclude{qw(pfappserver)} = ();
    our @files = grep { /\.pm$/  } _readDirRecursive('/usr/local/pf/html/pfappserver/lib/');
    our @libs = grep {!exists $exclude{$_}}
        map {
            s/\.pm$//;
            s#/#::#g;
            $_;
        } @files;

    plan tests => (scalar @libs)  + 1;

    foreach my $module ( @libs) {
        use_ok($module);
    }
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

1;
