#!/usr/bin/perl
use strict;
use warnings;
use Models; #Models
use Data::Dumper;
use List::Util qw(reduce);
exit main();

sub main{
    print("\t###Phrase-based SMT Eng-Jap###\n\n");
    print("init..\n");
    my $lang = _language_model();
    my %LangM = %{$lang};

    my $transl = _translation_model();
    my %Transl = %{$transl};
    open(my $langa, ">", "langm.txt");
    open(my $tran, ">", "tranm.txt");
    
    print $tran Dumper %{$transl};
    #print $langa Dumper %{_language_model()};
    #print Dumper %{$lang[1]};
    my $q;

    print("###Enter to Translate###");
    while($q = <STDIN>){
        print("\nEntry Query: ");
        
        chomp(my $q = <STDIN>);
        my @text = split(/ /, lc($q));
        unshift @text, "<s>";
        #push @text, '</s>';
        print(@text);
        print("\n");

        for(my $i = 1; $i <= $#text; $i++){
            #print("\n");
            
            if(!exists($LangM{$text[$i-1]}{$text[$i]})){
                $LangM{$text[$i-1]}{$text[$i]} = 0;
            }
            #print($LangM{$text[$i-1]}{$text[$i]});
            #print("\n");
            #print($text[$i-1]," ",$text[$i]);
            print(maxk($LangM{$text[$i-1]}{$text[$i]} ,$text[$i], $text[$i-1], \%Transl));
            #print("\n");


        }
    }
    
    
    
    return 0;    
}