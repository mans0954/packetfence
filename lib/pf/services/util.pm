package pf::services::util;
=head1 NAME

pf::services::util

=cut

=head1 DESCRIPTION

pf::services::util

Util functions for pf services

=cut

use strict;
use warnings;
use base qw(Exporter);
our @EXPORT = qw(daemonize createpid);
use pf::log;
use pf::log::trapper;
use pf::file_paths;
use Log::Log4perl::Level;
use File::Basename qw(basename);


=head2 daemonize

daemonize the service

=cut

sub daemonize {
    my ($service) = @_;
    my $logger = get_logger();
    chdir '/' or $logger->logdie("Can't chdir to /: $!");
    open STDIN, '<', '/dev/null'
        or $logger->logdie("Can't read /dev/null: $!");
    open STDOUT, '>', '/dev/null'
        or $logger->logdie("Can't open /dev/null: $!");
    open STDERR, '>', '/dev/null'
        or $logger->logdie("Can't open /dev/null: $!");
    tie *STDERR,'pf::log::trapper',$ERROR;
    tie *STDOUT,'pf::log::trapper',$DEBUG;
    my ($login,$pass,$uid,$gid) = getpwnam('pf')
        or die "pf not in passwd file";
    defined( my $pid = fork ) or $logger->logdie("$service could not fork: $!");
    POSIX::_exit(0) if ($pid);
    if ( !POSIX::setsid() ) {
        $logger->error("could not start a new session: $!");
    }
    createpid($service);
}

=head2 createpid

creates the pid file for the service

=cut

sub createpid {
    my ($pname) = @_;
    my $logger = get_logger;
    $pname = basename($0) if ( !$pname );
    my $pid     = $$;
    my $pidfile = $var_dir . "/run/$pname.pid";
    $logger->info("$pname starting and writing $pid to $pidfile");
    if ( open ( my $outfile, ">$pidfile") ) {
        print $outfile $pid;
        $outfile->close;
        return ($pid);
    } else {
        $logger->error("$pname: unable to open $pidfile for writing: $!");
        return (-1);
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

