package CGI::Wiki::Plugin::RSS::Reader;

use warnings;
use strict;
use vars qw( $VERSION @ISA );

$VERSION = '1.2';
@ISA = qw(CGI::Wiki::Plugin);

use Carp qw(croak);
use LWP::Simple;
use XML::RSS;

my $feed;
my $rss = XML::RSS->new;

sub new
{
    my $class  = shift;
    my %params = @_;
    my $self   = {};
    bless $self, $class;

    return $self->_init(%params);
}

sub _init
{
  my $self   = shift;
  my %params = @_;
  
  return unless $params{url} || $params{file};
  croak "'url' and 'file' cannot both be specified" if $params{url} && $params{file};

  $self->{_url}   = $params{url}  if $params{url};
  $self->{_file}  = $params{file} if $params{file};
  $self->{_debug} = 1 if $params{debug} && $params{debug} == 1;

  return $self;
}

sub retrieve
{
  my $self = shift;
  my $content;

  # Retrieve the RSS from the Net or open a local
  # file depending on how we were invoked.

  if ($self->{_url})
  {
    $content = get($self->{_url});
  }
  else
  {
    if (open RSS, $self->{_file})
    {
      $content .= $_ while <RSS>;
      close RSS;
    }
  }

  my $location;
  if ($self->{_url})
  {
    $location = $self->{_url};
  }
  else
  {
    $location = $self->{_file};
  }

  # If we couldn't get the RSS, fail silently or not?
  if (!defined $content)
  {
    return unless $self->{_debug};
    croak "Couldn't retrieve RSS from [$location]: $!";
  }

  $rss->parse($content);
   
  my @rss_items;

  foreach (@{$rss->{'items'}})
  {
    my $link;

    if ($_->{guid}) # RSS 2.0
    {
      $link = $_->{guid};
    }
    else
    {
      $link = $_->{link};
    }

    push @rss_items, {
                       title => $_->{title},
                       link  => $link
                     };
  }

  return @rss_items;
}

1;

__END__

=head1 NAME

CGI::Wiki::Plugin::RSS::Reader - retrieve RSS feeds for inclusion in CGI::Wiki nodes

=head1 DESCRIPTION

Use this L<CGI::Wiki> plugin to retrieve an RSS feed from a given URL so
that you can include it in a wiki node.

=head1 SYNOPSIS

    use CGI::Wiki::Plugin::RSS::Reader;

    my $rss = CGI::Wiki::Plugin::RSS::Reader->new(
      url   => 'http://example.com/feed.rss'
    );

    my @items = $rss->retrieve;

=head1 USAGE

This is a plugin for L<CGI::Wiki>, a toolkit for building wikis; therefore
please consult the documentation for L<CGI::Wiki> for relevant information.
This module can, however, be used standalone if you wish.

=head1 METHODS

=head2 C<new>

    my $rss = CGI::Wiki::Plugin::RSS::Reader->new([options]);

Create a new RSS reader. Valid options are C<url> or C<file> (a path to an
RSS file); only one can be specified.

=head2 C<retrieve>

    my @items = $rss->retrieve;

C<retrieve> will return an array of hashes, one for each item in the RSS
feed. The hashes contain two items, C<title> and C<link>.

If the URL or file you specified cannot be retrieved/read, C<retrieve> will
return undef rather than blowing up and surprising the person reading your
wiki. If you want, you can specify C<debug> to be 1 in the options to
C<new>, which will cause the module to croak instead of failing silently.

=head1 AUTHOR

Earle Martin (EMARTIN@cpan.org)

=head1 LEGAL

Copyright 2004 Earle Martin. 

This module is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut