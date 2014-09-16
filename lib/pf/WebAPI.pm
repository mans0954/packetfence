package pf::WebAPI;

=head1 NAME

WebAPI - Apache mod_perl wrapper to PFAPI (below).

=cut

use strict;
use warnings;

use Apache2::MPM ();
use Apache2::RequestRec;
use Log::Log4perl;
use ModPerl::Util;
use Apache2::Const -compile => qw(OK DECLINED HTTP_UNAUTHORIZED HTTP_NOT_IMPLEMENTED HTTP_UNSUPPORTED_MEDIA_TYPE HTTP_NO_CONTENT HTTP_NOT_FOUND);

BEGIN {
    use pf::log 'service' => 'httpd.webservices';
}

use pf::config;
use pf::api;

#uncomment for more debug information
#use SOAP::Lite +trace => [ fault => \&log_faults ];
use pf::WebAPI::RPC::MsgPack;
use pf::WebAPI::RPC::JSON;
use pf::WebAPI::RPC::Sereal;


# set proper logger tid based on if we are run from mod_perl or not
if (exists($ENV{MOD_PERL})) {
    if (Apache2::MPM->is_threaded) {
        require APR::OS;
        # apache threads
        Log::Log4perl::MDC->put('tid', APR::OS::current_thread_id());
    } else {
        # httpd processes
        Log::Log4perl::MDC->put('tid', $$);
    }
} else {
    # process threads
    require threads;
    Log::Log4perl::MDC->put('tid', threads->self->tid());
}

my $server_msgpack = pf::WebAPI::RPC::MsgPack->new({dispatch_to => 'pf::api'});
my $server_sereal = pf::WebAPI::RPC::Sereal->new({dispatch_to => 'pf::api'});
my $server_jsonrpc = pf::WebAPI::RPC::JSON->new({dispatch_to => 'pf::api'});

sub handler {
    my ($r) = @_;
    my $logger = get_logger;
    if (defined($r->headers_in->{Request})) {
        $r->user($r->headers_in->{Request});
    }
    my $content_type = $r->headers_in->{'Content-Type'};
    $logger->debug("Handling request for content type $content_type");
    if( $server_msgpack->allowed($content_type) ) {
        return $server_msgpack->handler($r);
    } elsif ($server_jsonrpc->allowed($content_type)) {
        return $server_jsonrpc->handler($r);
    } elsif ($server_sereal->allowed($content_type)) {
        return $server_sereal->handler($r);
    }
    return Apache2::Const::HTTP_UNSUPPORTED_MEDIA_TYPE;
}

sub log_faults {
    my $logger = get_logger;
    $logger->info(@_);
}

package PFAPI;
use base qw(pf::api);

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2014 Inverse inc.

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
