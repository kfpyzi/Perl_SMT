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

sub _translation_model{
    print("translation model entered...\n");

    my $TREN = "/Users/kylefarinas/Desktop/kyle/test/sys/small_parallel_enja-master/train.en";
    my $TRJA = "/Users/kylefarinas/Desktop/kyle/test/sys/small_parallel_enja-master/train.ja";

    open(my $bi, '>', 'BIENJA.txt');
    
    #open(my $bien, '<', $TREN) or die "data: $!\n";
    #open(my $bija, '<', $TRJA) or die "data: $!\n";



    open(my $bien, '<', $TREN) or die "data: $!\n"; 
    open(my $bija, '<', $TRJA) or die "data: $!\n";

    chomp(my @EN_TL = <$bien>);
    chomp(my @JP_TL = <$bija>);

    my @ENT_tokens = ();
    foreach my $EN_T (@EN_TL){
        my @EN_token = split(/ /, $EN_T);
        push @EN_token, "</s>";
        unshift @EN_token, "<s>";
        push (@ENT_tokens, [@EN_token]);
    }

    my @JPT_tokens = ();
    foreach my $JP_T (@JP_TL){
        my @JP_token = split(/ /, $JP_T);
        push @JP_token, "</s>";
        unshift @JP_token, "<s>";
        push (@JPT_tokens, [@JP_token]);
    }

    my %TJ;
    my %CEJ;
    my %TEF;
    foreach my $x (0.. ($#ENT_tokens + $#JPT_tokens)/2){
        my @arr = @{$ENT_tokens[$x]};
        my @arr2 = @{$JPT_tokens[$x]};
        #set count(e|f) to 0 for all e,f
        for(my $i = 0; $i < $#arr; $i++){
            
            for (my $j = 0; $j < $#arr2; $j++){
                $CEJ{$arr[$i]}{$arr2[$j]} = 0;
                $TEF{$arr[$i]}{$arr2[$j]}++;
                #$TJ{$arr2[$j]} = 0;
                #print($CEJ{$arr[$i]}{$arr2[$j]});
            }
        }
        #set total(f) to 0 for all f
        for (my $a = 0; $a < $#arr2; $a++){
            $TJ{$arr2[$a]} = 0;
        }
    }

    my %TSE;
    #for all sentence pairs
    foreach my $y (0.. ($#ENT_tokens + $#JP_T)/2){
        my @arrE = @{$ENT_tokens[$y]};
        my @arrJ = @{$JPT_tokens[$y]};
        #set total_se = 0
        for(my $i = 0; $i < $#arrE; $i++){
            $TSE{$arrE[$i]} = 0;
        }
=pod
        for all words e in e_s
            for all words f in f_s
                total_s(e) += t(e|f)
        for all words e in e_s
            for all words f in f_s
                count(e|f) += t(e|f) / total_s(e)
                total(f)   += t(e|f) / total_s(e)
=cut
        for(my $se = 0; $se < $#arrE; $se++){
            for(my $sj = 0; $sj < $#arrJ; $sj++){
                $TSE{$arrE[$se]} += $TEF{$arrE[$se]}{$arrJ[$sj]};
                $CEJ{$arrE[$se]}{$arrJ[$sj]} += $TEF{$arrE[$se]}{$arrJ[$sj]} / $TSE{$arrE[$se]};
                $TJ{$arrJ[$sj]} += $TEF{$arrE[$se]}{$arrJ[$sj]} / $TSE{$arrE[$se]};
            }
        }


    }

    foreach my $z (0.. ($#ENT_tokens + $#JP_T)/2){
        my @arrEF = @{$ENT_tokens[$z]};
        my @arrJF = @{$JPT_tokens[$z]};
        for(my $i = 0; $i < $#arrEF; $i++){
            for (my $j = 0; $j < $#arrJF; $j++){
                
                $TEF{$arrEF[$i]}{$arrJF[$j]} = $CEJ{$arrEF[$i]}{$arrJF[$j]} / $TJ{$arrJF[$j]};
            }
        }
    }

    #print Dumper @ENT_tokens;

    print("translation model created...\n");
    #print Dumper @JPT_tokens;
    return \%TEF;
    print("\n");    
    
    
}

1;
