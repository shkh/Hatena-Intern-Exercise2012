package TemplateEngine;

use strict;
use warnings;
use utf8;

binmode STDOUT, ':utf8';

sub new{
    my ($class, %hsh) = @_;

    open my $template, "$hsh{file}"
        or die "Could not open $hsh{file} : $!\n";
    
    bless {file_ref => $template}, $class;
}

sub render{
    my ($self, $hsh_ref) = @_;
   
    my $template = ${$self}{file_ref};
    my $lines = join '', <$template>;
    
    for my $key (keys %$hsh_ref){
        my $value = $$hsh_ref{$key};

        $value =~ s/&/&amp;/g;
        $value =~ s/>/&gt;/g;
        $value =~ s/</&lt;/g;
        $value =~ s/"/&quot;/g;
    
        $lines =~ s/{\s*%\s+$key\s+%\s*}/$value/g;
    }

    #値がないときは空にする
    $lines =~ s/{\s*%\s+\w+\s+%\s*}//g;
    
    $lines;
}

1;
