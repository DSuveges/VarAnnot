package GetGWAVA;

=head1 Description

This module calls GWAVA to provide functional annotation for variations in the non-coding region.

More information of the method: L< G. Ritchie 2014 Functional annotation of noncoding sequence variants | http://www.nature.com/nmeth/journal/v11/n3/full/nmeth.2832.html >

=head1 Requirements

GWAVA requires a handful of python packages and external programs including samtools.
In this script, all the paths to relevant sources are included.

=head1 SYNOPSIS

    use GetGWAVA ".";
    my %hash = ();

    # Run GWAVA:
    ($input_lines, $fields) = GetGWAVA::GetGWAVA($input_lines, $window, $fields);


=head1 Input:

    The function uses chromosome and start and end positions to perform annotation. This
    information should be organized in the following format:

    $hash{$line_no}{
        'chr'   => <X>,              # chromosome
        'start' => <position>,       # start position of the variant
        'end'   => <position>,       # end position of the variant
    }

=head1 Output

    After successful calling and parsing the output files of GWAVA, the input
    hash will be updated with the follwing fields:

    $hash{$line_no}{
        'chr'           => <X>, # chromosome
        'start'         => "-", # start position of the variant
        'end'           => "-", # end position of the variant
        "DNase"         => "-", # DNase motifs
        "avg_gerp"      => "-", # avreage GERP score
        "gerp"          => "-", # GERP score
        "dnase_fps"     => "-", # DNase footprints
        "bound_motifs"  => "-", # Number of bound motifs
        "GWAVA_score"   => "-"  # GWAVA score
    }

=head1 Version

    v.1.0 Last modified: 2015.12.18

=cut


use strict;
use warnings;

sub GetGWAVA {

    # Input data:
    my %hash      = %{$_[0]};
    my @AllFields = @{$_[2]};

    # Generate random file names
    my $temporarySuffix = int(rand(10000));
    my $tempBedfile     = sprintf("/tmp/varAnnotation_GWAVA_input_%s.bed",  $temporarySuffix);
    my $tempGWAVAannot  = sprintf("/tmp/varAnnotation_GWAVA_annot_%s.csv",  $temporarySuffix);
    my $tempGWAVAscore  = sprintf("/tmp/varAnnotation_GWAVA_scores_%s.bed", $temporarySuffix);

    # If we can't open the bedfile for write, we return without doing anything.
    my $OUTBED;
    unless ( open($OUTBED, ">", $tempBedfile )){
        return (\%hash, \@AllFields);
        print STDERR  "[Error] GWAVA annotation failed: temporary file could not be oppened: $tempBedfile\n";
    }

    # Writing out bedfile with all variations:
    foreach my $key (keys %hash){

        # The corresponding fields will be extracted from the main hash:
        my $chr   = $hash{$key}->{"chr"};
        my $start = $hash{$key}->{"start"};
        my $end   = $hash{$key}->{"end"};
        my $input = $hash{$key}->{"input"};

        # all entries are saved in a temporary file.
        printf $OUTBED "chr%s\t%s\t%s\t%s\n", $chr, $start-1, $end, $input;
    }

    # Hardwired paths to python folders, and gwava directory.
    my $pythonDir = "'/nfs/team144/software/anaconda/lib/python2.7/site-packages'";
    my $path = "'/software/hgi/pkglocal/samtools-1.2/bin:/software/hgi/pkglocal/vcftools-0.1.11/bin:/software/hgi/pkglocal/tabix-git-1ae158a/bin:/software/hgi/pkglocal/bcftools-1.2/bin:/nfs/team144/software/ensembl-releases/75/ensembl-tools/scripts/variant_effect_predictor:/nfs/team144/software/bedtools2/bin:/nfs/team144/software/scripts:/nfs/users/nfs_d/ds26/bin:/usr/local/lsf/9.1/linux2.6-glibc2.3-x86_64/etc:/usr/local/lsf/9.1/linux2.6-glibc2.3-x86_64/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/software/bin'";
    my $gwavaDir  = "'/lustre/scratch113/teams/zeggini/users/ds26/GWAVA/gwava_release'";

    # Checking samtools
    my $samtools = `export PATH=\$PATH:$pythonDir; samtools --version | head -1`;
    unless ($samtools){
        print STDERR "[Warning] Samtools was not found in path! Use: 'module add hgi/samtools/latest'\n";
        print STDERR "[Warning] GWAVA calculations will be skipped. Returning to main program.\n";
        return (\%hash, \@AllFields);
    }
    printf STDERR "[Info] Using %s", $samtools;

    # Status update:
    print STDERR "[Info] Now, performing GWAVA calculations.\n";

    # Run gwava annotation script:
    `sort -k1,1 -k2,2n $tempBedfile -o $tempBedfile`;
    `export PYTHONPATH=$pythonDir; export PATH=$path:\$PATH; export GWAVA_DIR=$gwavaDir; python $gwavaDir/src/gwava_annotate.py $tempBedfile $tempGWAVAannot`;

    # Run gwava prediction script:
    unless (-e $tempGWAVAannot){
        print STDERR "[Error] The GWAVA annotation scrip failed: the annotation file ($tempGWAVAannot) was not created.\n";
        `rm $tempBedfile`;
        return (\%hash, \@AllFields);
    }

    # run gwava:
    `export PYTHONPATH=$pythonDir; export PATH=$path:\$PATH; export GWAVA_DIR=$gwavaDir; python $gwavaDir/src/gwava.py tss $tempGWAVAannot $tempGWAVAscore`;

    # Checking if the GWAVA run was successful or not:
    unless (-e $tempGWAVAscore){
        print STDERR "[Error] The GWAVA prediction scrip did not run successfully. The score file ($tempGWAVAscore) was not created.\n";
        `rm $tempBedfile`;
        `rm $tempGWAVAannot`;
        return (\%hash, \@AllFields);
    }

    # Process output file. Update hash
    my ($hash, $AllFields) = &parse_GWAVA_File(\%hash, \@AllFields, $tempGWAVAannot, $tempGWAVAscore);

    # remove temporary files.
    #`rm $tempBedfile`;
    #`rm $tempGWAVAannot`;
    #`rm $tempGWAVAscore`;

    # Returning data:
    return ($hash, $AllFields);
}


sub parse_GWAVA_File{

    # input variables have been processed:
    my %hash        = %{$_[0]};
    my @AllFields   = @{$_[1]};
    my $gwava_annot = $_[2];
    my $gwava_file  = $_[3];

    # processing annotation file:
    my $annotation = `cat $gwava_annot | cut -d"," -f1,148,149,159,160,21`;

    my @lines = split("\n", $annotation);
    my %GWAVA_annotation;
    for (my $index = 0; $index < scalar(@lines); $index++){

        # Testing if the proper columns have been selected:
        if ($index == 0) {
            unless ($lines[$index] eq ",DNase,avg_gerp,gerp,dnase_fps,bound_motifs"){
                printf STDERR "[Warning] GWAVA annotation file header is not as expected: %s, Check GetGWAVA.pm!\n";
                printf STDERR "[Warning] GWAVA annotation skipped\n";
                return (\%hash, \@AllFields);
            }
            next; # If the header looks OK, we move to the next line.
        }

        my @fields = split(",", $lines[$index]);

        # Looping through all lines:
        $GWAVA_annotation{$fields[0]} = {
            "DNase"     => $fields[1],
            "avg_gerp"  => $fields[2],
            "gerp"      => $fields[3],
            "dnase_fps" => $fields[4],
            "bound_motifs" => $fields[5],
            "GWAVA_score" => "-"
        };
    }

    # processing annotation file:
    $annotation = `cat $gwava_file | cut -d"," -f1,148,149,159,160,21`;
    @lines = split("\n", $annotation);
    for (my $index = 0; $index < scalar(@lines); $index++){
        my @fields = split("\t", $lines[$index]);

        # Looping through all lines:
        $GWAVA_annotation{$fields[3]}{"GWAVA_score"} = $fields[4] if $fields[4] and $fields[3];
    }

    # Updating field list:
    push (@AllFields, ("GWAVA_score", "avg_gerp", "gerp", "DNase", "dnase_fps", "bound_motifs"));

    # Looping through all variations and updating the main hash:
    foreach my $key (keys %hash){

        # find key:
        my $input = $hash{$key}{"input"};

        # Updating hash:
        $hash{$key}{"GWAVA_score"}  =  $GWAVA_annotation{$input}{"GWAVA_score"};
        $hash{$key}{"avg_gerp"}     =  $GWAVA_annotation{$input}{"avg_gerp"};
        $hash{$key}{"gerp"}         =  $GWAVA_annotation{$input}{"gerp"};
        $hash{$key}{"DNase"}        =  $GWAVA_annotation{$input}{"DNase"};
        $hash{$key}{"dnase_fps"}    =  $GWAVA_annotation{$input}{"dnase_fps"};
        $hash{$key}{"bound_motifs"} =  $GWAVA_annotation{$input}{"bound_motifs"};
    }

    return (\%hash, \@AllFields);

}

1;