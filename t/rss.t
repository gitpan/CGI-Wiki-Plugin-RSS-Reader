#!/usr/bin/perl

use warnings;
use strict;

# -------------------------------------------------
# Here we fake connecting to the Net and getting
# back an RSS file. Thanks to Mark Fowler for this.

package LWP::Simple;

use vars qw(@EXPORT $RSS);
use base qw(Exporter);
@EXPORT = qw(get);

$RSS = qq{<?xml version="1.0" ?>

<!DOCTYPE rss PUBLIC "-//Netscape Communications//DTD RSS 0.91//EN" 
  "http://my.netscape.com/publish/formats/rss-0.91.dtd"> 

<rss version="0.91">
  <channel>
    <title>Example</title>
    <link>http://example.com/</link>
    <item>
      <title>Example item 1</title>
      <link>http://example.com/1.html</link>
    </item>
    <item>
      <title>Example item 2</title>
      <link>http://example.com/2.html</link>
    </item>
    <item>
      <title>Example item 3</title>
      <link>http://example.com/3.html</link>
    </item>
  </channel>
</rss>};

sub get
{
  return $RSS;
}

$INC{"LWP/Simple.pm"} = 1;

# -------------------------------------------------

package main;

use Test::More tests => 7;

# Create a temporary file, fill it with the RSS we defined
# earlier in the fake LWP::Simple.

use File::Temp qw(tempfile);
my ($tmp, $rss_file) = tempfile();
print $tmp $LWP::Simple::RSS;
close $tmp;

#1
use_ok("CGI::Wiki::Plugin::RSS::Reader");

my $rss = CGI::Wiki::Plugin::RSS::Reader->new(
  file => $rss_file,
);

#2
isa_ok($rss, "CGI::Wiki::Plugin");

my @items = $rss->retrieve;

#3
is($items[0]{title}, 'Example item 1', 'Got local title');

#4
is($items[0]{link}, 'http://example.com/1.html', 'Got local link');

$rss = CGI::Wiki::Plugin::RSS::Reader->new(
  url => 'http://example.com/example.rss',
);

@items = $rss->retrieve;

#5
is($items[0]{title}, 'Example item 1', 'Got remote title');

#6
is($items[0]{link}, 'http://example.com/1.html', 'Got remote link');

my $died;

eval {
  local $SIG{__DIE__} = sub { $died = 1; };

  # Illegal usage.
  $rss = CGI::Wiki::Plugin::RSS::Reader->new(
    url  => 'http://example.com/example.rss',
    file => $rss_file,
  );
};

#7
is($died, 1, 'Caught illegal config options');

