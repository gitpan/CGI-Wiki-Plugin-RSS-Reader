#!/usr/bin/perl

use strict;

use Module::Build;

Module::Build->new(
  module_name  => 'CGI::Wiki::Plugin::RSS::Reader',
  requires     => {
                    'LWP::Simple' => 0,
                    'XML::RSS'    => 0,
                  },
  license      => 'perl'
)->create_build_script;