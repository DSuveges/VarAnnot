package GetMAFs;

use strict;
use warnings;
use RESTsubmit ".";


# This routine downloads the frequency of the non-reference allele.
# input:
    # Usual format of the input lines.
    #    hash{line#}->{
    #            "rsID"             => #,
    #            "ref"              => #,
    #            "ancestral_allele" => #,

# If there is no valid rsid (value stored in the rsID), no check for frequencies

# Output:
    # new keys are added to hash:
    #    hash{line#}->{
    #        "Variant_Freq_CEU" = "-";
    #        "Variant_Freq_TSI" = "-";
    #        "Variant_Freq_FIN" = "-";
    #        "Variant_Freq_GBR" = "-";
    #        "Variant_Freq_IBS" = "-";
sub MAFs {
    print STDERR "[Info] Retrieving MAF information.";

    my %variants = %{$_[0]};
    my @Fields   = @{$_[1]};

    my $Eur_pops = "CEU, TSI, FIN, GBR, IBS";

    my @ProteinFields = ("Variant_Freq_CEU", "Variant_Freq_TSI", "Variant_Freq_FIN", "Variant_Freq_GBR", "Variant_Freq_IBS");
    push(@Fields, @ProteinFields);

    foreach my $variant (keys %variants){

        # Keeping track of progression:
        print STDERR ".";

        # Initializing values to be returned:
        $variants{$variant}->{"Variant_Freq_CEU"} = "-";
        $variants{$variant}->{"Variant_Freq_TSI"} = "-";
        $variants{$variant}->{"Variant_Freq_FIN"} = "-";
        $variants{$variant}->{"Variant_Freq_GBR"} = "-";
        $variants{$variant}->{"Variant_Freq_IBS"} = "-";

        # We don't care variants that don't have a valid rsID:
        # These variants are not expected to be seen in the poulation database.
        next if $variants{$variant}->{"matching_rsID"} eq "-";

        # rsid and the alternative allele are required to retrieve and parse the returned data:
        my $rsid      = $variants{$variant}->{"matching_rsID"};
        my $ancestral = $variants{$variant}->{"ancestral_allele"};
        $ancestral    = $variants{$variant}->{"ref"} if $ancestral eq "-";

        my $URL  = sprintf("http://rest.ensembl.org/variation/human/%s?content-type=application/json&pops=1", $rsid);
        my $data = RESTsubmit::REST($URL);

        # If there was some problem:
        next unless ref $data eq "HASH";

        if ( $data->{ancestral_allele} ) {
            $ancestral = $data->{ancestral_allele};
        }

        # Looping through all available populations:
        foreach my $popdata (@{$data->{"populations"}}) {

            my $pop = substr($popdata->{population}, - 3); # Get the three letter code of the population.


            # We care only about those populations that are listed in the Eur_pops variable.
            next unless $Eur_pops =~ /$pop/;

            if ($popdata->{allele} eq $ancestral){ # Frequency of the ancestral variant
                $variants{$variant}->{"Variant_Freq_$pop"} = 1 - $popdata->{frequency} unless $variants{$variant} eq "-";
            }
            else{# Frequency of the alternate variant
                $variants{$variant}->{"Variant_Freq_$pop"} = $popdata->{frequency} unless $variants{$variant} eq "-";
            }
        }
    }

    print STDERR " done.\n";
    return (\%variants, \@Fields);
}
1;