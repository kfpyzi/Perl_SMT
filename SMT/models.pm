package Models;

#use strict;
use warnings;

use Exporter;

our @ISA = qw(Exporter);
our @EXPORT = qw(_language_model _translation_model );
use Data::Dumper;

sub _language_model{

    print("language model entered...\n");
    #Parallel Corpus Eng-Jap
    my $DEVEN = "/Users/kylefarinas/Desktop/kyle/test/sys/small_parallel_enja-master/train.en";

    open(my $enf, '<', $DEVEN) or die "data: $!\n";
    chomp(my @EN_lines = <$enf>);

    my @EN_tokens = ();
    foreach my $EN_pline (@EN_lines){
        my @EN_token = split(/ /, $EN_pline);
        push @EN_token, "</s>";
        unshift @EN_token, "<s>";
        push (@EN_tokens, [@EN_token]);
    }


    my %counts;
    my %context_counts;
    
    foreach my $line (@EN_tokens){
        my @inline = @{$line};
        for(my $i = 1; $i < $#inline - 1; $i++){
            $counts{$inline[$i-1]," ",$inline[$i]}++;
            $context_counts{$inline[$i-1]}++;
            $counts{$inline[$i]}++;
            $context_counts{""}++;
        }
    
    }
    my %LPB;
    open(my $LM, '>>','languagemodel.txt');
    foreach my $pbline (@EN_tokens){
        my @inline = @{$pbline};
        for(my $i = 1; $i < $#inline - 1; $i++){
            my $pb = $counts{$inline[$i-1]," ",$inline[$i]} / $context_counts{$inline[$i-1]};
            $LPB{$inline[$i-1]}{$inline[$i]} = $pb;
            print $LM ($inline[$i-1],"|",$inline[$i],"|",$pb,"\n"); 
        }    
    }
    print("language model created...\n");
    return \%LPB;
    print("\n");    
    
}
