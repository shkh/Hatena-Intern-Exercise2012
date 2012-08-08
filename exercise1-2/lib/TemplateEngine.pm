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

    while ($lines =~ /{\s*\s+for\s+\w+\s+in\s+\w+\s+%\s*}/){ #おかしい
        $lines = makeForTree([], $lines, $hsh_ref);

    }
    #$lines = makeForTree([], $lines, $hsh_ref);

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


#ほぼバグ
sub makeForTree{
    
    my $forarr = shift;
    my $lines = shift;
    my $hsh = shift;

    my ($before, $after);

    #forとendforの対応が確定していないとき
    if ($lines =~ /(?<begin>{\s*%\s+for\s+\w+\s+in\s+\w+\s+%\s*})(?<content>.*){\s*%\s+endfor\s+%\s*}/){ #正規表現がおかしい
     
        push @$forarr, $+{begin};
        ($before, $after) = makeForTree($forarr, $+{content}, $hsh);

    #forとendforの対応が確定したとき
    }elsif ($lines =~ /{\s*%\s+endfor\s+%\s*}/){
       
        my $begin = pop @$forarr;
        
        $begin =~ /for\s+(?<counter>\w+)\s+in\s+(?<target>\w+)/;
        my ($counter, $target) = ($+{counter}, $+{target});
        
        $lines =~ /$begin(?<content>.*){\s*%\s+endfor\s+%\s*}/;
        my $content = $+{content};
        my $element = $&;

        #ここで親の変数を置換する
        
        my $tmp_lines;
        for (@$hsh{$target}){
            my $tmp_content = $content;
            $tmp_lines += $tmp_content =~ s/{\s*%\s+$counter\s+%\s*}/$_/g;
        }
        
        #確定した部分を置き換える
        $lines =~ s/$element/$tmp_lines/;

        #大元の$linesで$elementを$linesで置き換える
        return ($element, $lines);
    }

    #ここ何か足りない

    #大元の$linesで、確定した部分を置き換える
    $lines =~ s/$before/$after/;
    
    #あとは対応が取れているので最短一致で置き換える
    while (my $begin = pop @$forarr){

        $begin =~ /for\s*(?<counter>\w+)in\s+(?<target>\w+)/;
        my ($counter, $target) = ($+{counter}, $+{target});

        $lines =~ /$begin(?<content>.*?){\s*%\s+endfor\s+%\s*}/;
        my $content = $+{content};
        my $element = $&;

        my $tmp_lines;
        for (@$hsh{$target}){
            my $tmp_content = $content;
            $tmp_lines += $tmp_content =~ s/{\s*%\s+$counter\s+%\s*}/$_/g;
        }

        $lines =~ s/$element/$tmp_lines/;
    }

    $lines;
    
}

1;
