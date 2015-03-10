package pf::api::jsonrpcclient;

=head1 NAME

pf::api::jsonrpcclient

=head1 SYNOPSIS

  use pf::api::jsonrpcclient;
  my $client = pf::api::jsonrpcclient->new;
  my @args = $client->call("echo","packet","fence");

  $client->notify("echo","packet","fence");


=head1 DESCRIPTION

  pf::api::jsonrpcclient is a jsonrpc client over http

=cut

use strict;
use warnings;

use pf::config;
use pf::log;
use WWW::Curl::Easy;
use JSON::XS;
use Moo;
use HTTP::Status qw(:constants);

=head1 Attributes

=head2 username

  the username of the rpc call

=cut

has username => ( is => 'rw', default => sub {$Config{'webservices'}{'user'}} );

=head2 password

  the password of the rpc call

=cut

has password => ( is => 'rw', default => sub {$Config{'webservices'}{'pass'}} );

=head2 proto

  the protocol of the rpc call http or https
  default http

=cut

has proto => ( is => 'rw', default => sub {$Config{'webservices'}{'proto'}} );

=head2 host

  the host of the rpc server
  default 127.0.0.1

=cut

has host => ( is => 'rw', default => sub {$Config{'webservices'}{'host'}} );

=head2 port

  the port of the rpc server
  default 9090

=cut

has port => (is => 'rw', default => sub {$Config{'webservices'}{'port'}} );

=head2 id

  the id of the message it is incremented after each call
  default 0

=cut

has id => (is => 'rw', default => sub {0} );

use constant REQUEST => 0;
use constant RESPONSE => 2;
use constant NOTIFICATION => 2;

=head1 METHODS

=head2 call

  Calls an rpc method

=cut

sub call {
    use bytes;
    my ($self,$function,@args) = @_;
    my $response;
    my $curl = $self->curl($function);
    my $request = $self->build_jsonrpc_request($function,\@args);
    my $response_body;
    $curl->setopt(CURLOPT_POSTFIELDSIZE,length($request));
    $curl->setopt(CURLOPT_POSTFIELDS, $request);
    $curl->setopt(CURLOPT_WRITEDATA, \$response_body);

    # Starts the actual request
    my $curl_return_code = $curl->perform;

    # Looking at the results...
    if ( $curl_return_code == 0 ) {
        my $response_code = $curl->getinfo(CURLINFO_HTTP_CODE);
        if($response_code == 200) {
            $response = decode_json($response_body);
        } else {
            $response = decode_json($response_body);
            die $response->{error}{message};
        }
    } else {
        my $msg = "An error occured while sending a JSONRPC request: $curl_return_code ".$curl->strerror($curl_return_code)." ".$curl->errbuf;
        die $msg;
    }

    return @{$response->{result}};
}

=head2 notify

  Send a notification message to the rpc server

=cut

sub notify {
    use bytes;
    my ($self,$function,@args) = @_;
    my $response;
    my $curl = $self->curl($function);
    my $request = $self->build_jsonrpc_notification($function,\@args);
    my $response_body;
    $curl->setopt(CURLOPT_POSTFIELDSIZE,length($request));
    $curl->setopt(CURLOPT_POSTFIELDS, $request);
    $curl->setopt(CURLOPT_WRITEDATA, \$response_body);

    # Starts the actual request
    my $curl_return_code = $curl->perform;

    # Looking at the results...
    if ( $curl_return_code == 0 ) {
        my $response_code = $curl->getinfo(CURLINFO_HTTP_CODE);
        if($response_code != HTTP_NO_CONTENT) {
            get_logger->error( "An error occured while processing the JSONRPC request return code ($response_code)");
        }
    } else {
        get_logger->error("An error occured while sending a JSONRPC request: $curl_return_code ".$curl->strerror($curl_return_code)." ".$curl->errbuf);
    }
    return;
}

=head2 curl

  Creates a curl object to connect to the rpc server

=cut

sub curl {
    my ($self,$function) = @_;
    my $url = $self->url;
    my $curl = WWW::Curl::Easy->new;
    $curl->setopt(CURLOPT_HEADER, 0);
    $curl->setopt(CURLOPT_DNS_USE_GLOBAL_CACHE, 0);
    $curl->setopt(CURLOPT_NOSIGNAL, 1);
    $curl->setopt(CURLOPT_URL, $url);
    $curl->setopt(CURLOPT_HTTPHEADER, ['Content-Type: application/json-rpc',"Request: $function"]);
    if($self->username && $self->password && ($self->proto eq 'https') ) {
        $curl->setopt(CURLOPT_HTTPAUTH, CURLOPT_HTTPAUTH);
        $curl->setopt(CURLOPT_USERNAME, $self->username);
        $curl->setopt(CURLOPT_PASSWORD, $self->password);
        # Removed SSL verification
        $curl->setopt(CURLOPT_SSL_VERIFYHOST, 0);
        $curl->setopt(CURLOPT_SSL_VERIFYPEER, 0);
    }
    return $curl;
}

=head2 url

  The url to the rpc message to

=cut

sub url {
    my ($self) = @_;
    my $proto = $self->proto;
    my $host = $self->host;
    my $port = $self->port;
    return "${proto}://${host}:${port}";
}

=head2 build_jsonrpc_request

  builds the jsonrpc request

=cut

sub build_jsonrpc_request {
    my ($self,$function,$args) = @_;
    my $id = $self->id;
    my $request = {method => $function, jsonrpc => '2.0', id => $id , params => $args };
    $id++;
    $self->id($id);
    return encode_json $request;
}

=head2 build_jsonrpc_notification

  builds the jsonrpc notification request

=cut

sub build_jsonrpc_notification {
    my ($self,$function,$args) = @_;
    my $request = {method => $function, jsonrpc => '2.0', params => $args };
    return encode_json $request;
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

