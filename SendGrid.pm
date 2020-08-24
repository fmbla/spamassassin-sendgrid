# <@LICENSE>
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to you under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at:
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# </@LICENSE>

# Author:  Paul Stead <paul.stead@zeninternet.co.uk>

=head1 NAME

Sendgrid Sender Token

=head1 SYNOPSIS

  loadplugin    Mail::SpamAssassin::Plugin::SendGrid

=head1 DESCRIPTION

Extract SendGrid ID from a message to the tag SENDGRID_ID, this tag can be used with other plugins, including askdns

=cut

package Mail::SpamAssassin::Plugin::SendGrid;
my $VERSION = 0.1;

use strict;
use Mail::SpamAssassin::Plugin;
use vars qw(@ISA);
@ISA = qw(Mail::SpamAssassin::Plugin);

sub dbg {
  Mail::SpamAssassin::Plugin::dbg ("SendGrid: @_");
}

sub new {
  my ($class, $mailsa) = @_;

  $class = ref($class) || $class;
  my $self = $class->SUPER::new($mailsa);
  bless ($self, $class);

  return $self;
}

sub parsed_metadata {
  my ($self, $params) = @_;
  my ($pms) = $params->{permsgstatus};
  my $sendgrid_id;

  my $sg_eid = $pms->get("X-SG-EID", undef);
  return if not defined $sg_eid;

  my $envfrom = $pms->get("EnvelopeFrom:addr", undef);

  if($envfrom =~ /bounces\+(\d+)\-/) {
    $sendgrid_id = $1;
    # dbg("ENVFROM: $envfrom ID: $sendgrid_id");
    if(defined $sendgrid_id) {
      $pms->set_tag('SENDGRID_ID', $sendgrid_id);
    }
  }

  return 1;
}

1;
