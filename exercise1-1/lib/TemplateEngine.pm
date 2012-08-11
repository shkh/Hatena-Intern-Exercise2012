package TemplateEngine;

use strict;
use warnings;
use utf8;
use IO::File;
use HTML::Entities;


binmode STDOUT, ':utf8';

sub new{
    my ($class, %args) = @_;
    
    my $template = new IO::File->new("$args{file}", "r");
    
    bless {file_ref=> $template}, $class;
}

sub render{
    my ($self, $args) = @_;
   
    my $template = ${$self}{file_ref};
    my $lines = join '', $template->getlines;

    my %escaped_args = map { $_ => encode_entities($$args{$_}, '<>&"') } keys %$args;
    $lines =~ s/{\s*%\s+(\w+)\s+%\s*}/$escaped_args{$1}/g;
    
    $lines;
}

1;
