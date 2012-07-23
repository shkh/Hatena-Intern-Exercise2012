package TemplateEngine;

use strict;
use warnings;
use utf8;
use Encode;

sub new{
    my ($self, %hsh) = @_;

    open my $template, "$hsh{file}"
        or die "ファイル開けない $!\n";

    bless $template, $self;
}

sub render{
    my ($self, $hsh_ref) = @_;
    
    my $lines = join '', <$self>;
    
    my %esc_hsh = (
        '&' => '&amp;', 
        '>' => '&gt;', 
        '<' => '&lt;', 
        '"' => '&quot;', 
    );
    
    for my $key (keys %$hsh_ref){
        my $value = $$hsh_ref{$key};

        for my $esc_key (keys %esc_hsh){
            $value =~ s/${esc_key}/$esc_hsh{$esc_key}/g;
        }

        #$value =~ s/&/&amp;/g;
        #$value =~ s/>/&gt;/g;
        #$value =~ s/</&lt;/g;
        #$value =~ s/"/&quot;/g;
    
        $lines =~ s/{\s*%\s+$key\s+%\s*}/$value/g;
    }
    
    return encode('utf8', $lines); 
}

1;
