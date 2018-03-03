#!/usr/local/bin/perl

# Version: 1.3 Last modified: 2015.12.21

# New in this version:
    # Usage compatible with older version
    # customizable window size for gwas search
    # customizable output field separator
    # input can be read from stdin/pipe or file
    # functions are more robust
    # more informative error messages
    # GWAVA, gerp scores optionally added

# For a more complete documentation, see
    # perldoc VarAnnot.pl

# For more information of the applied methods, see documentation of the
# individual packages.

=head1 Description

This script was written to provide high-throughput annotation for variations.
The script returns information from various sources and outputs a table with
each queried variations in each line.

=head1 Version

B<v.1.3> Last modified B<2015.12.21>

=head1 Requirements

The script uses the following perl packages: B<HTTP::tiny>, B<POSIX>, B<JSON>, B<Data::Dumper>

External programs in path: B<bedtools>,

=head1 Usage

=head2 B<Reading input from file:> C<perl VarAnnot.pl -g -d <Delimiter> -w <Window>  <Input_file> >

=over 2

=over 2

=item B<g>

g is switch, does not takes an argument. When provided, GWAVA score will also be calculated for
each variations. (By default, GWAVA calculation is turned off for faster run)

=item B<Delimiter:>

Delimiter is an B<optional> parameter, it's default value is B<,>. User specified delimiter
can be any string. If a field contains the provided delimiter, it will be double quoted.
A safe choice for delimitter is tab: "\t".

=item B<Window length:>

Window length specifies the distance within any known GWAS signals will be reported.
It's an B<optional> parameter, its default value is B<500000bp>. Provide just the
distances in basepairs without the bp notation. If non-regular window length is
specified, the default value will be used.

=item B<input file:>

If no file is given, the script will expect input from the standard input.
For the input format see
input section.

=back

=back

=head1 Input

The script accepts a list of variations where each variation is in a new line.
If there are more variations in one line, only the first will be considered!
Variations can be defined by their B<rsID> or B<SNP ID>.

The preferred format: B<chr{chr}:{start}-{end}_{a1}_{a2}>
Where either a1 or a2 has to mach the reference sequence. In there is no match,
a1 will be used as reference, and a2 as alternative.

SNP ID (chr{chr}:{pos}) is also accepted, in this case the alternative allele can not
be calculated, and only overlapping rsIDs will returned, but exact matches can not be established.

=head1 Output

As the script proceeds, many status updates are printed to the standard error.
Then output is printed to standard output. Where the first row is a header with
all field names, then each queried variations are in a separate line.

If there are known gwas signals within the specified distance, a formatted table
is saved to a separated file: B<./gwas_signals.tsv>

=head1 Contact

With questions and problems please contact me: ds26@sanger.ac.uk

=cut

use strict;
use warnings;
use Data::Dumper;
use POSIX;

# Before loading custom packages, we have to add package folder to the @inc:
use lib "/nfs/team144/ds26/FunctionalAnnotation/v1.3/packages";

use BasicInformation ;
use GWAStest ;
use GetGene ;
use GetProtein ;
use GetConsequence ;
use GetMAFs ;
use GetGWAVA;
use Getopt::Std;

# Expected arguments:
getopts('gd:w:');
# g - gwava turning on, default: off
# d - delimiter, default: "," (takes argumetn)
# w - window, default: 500kbp (takes argument)

# taking options
our($opt_g, $opt_d, $opt_w);

# Reading default values of parameters:
my $delimiter = $opt_d // ",";
my $window = $opt_w // 500000;
my $gwava = $opt_g // 0;

# Checking if the provided window length is proper:
unless ( isdigit($window) ) {
    printf STDERR "[Warning] The provided window length is not and integer: %s. No abbreviations are accepted eg. bp/kbp/Mbp!\n[Warning] Window size is set to default: 500000.\n", $window;
    $window = 500000;
}

# Reporting initial parameters:
my $file = "standard input";
$file = $ARGV[0] if $ARGV[0];
printf STDERR "[Info] Reading input from: %s\n", $file;
printf STDERR "[Info] Output delimiter: %s\n", $delimiter;
printf STDERR "[Info] Window size for GWAS filtering: %s\n", $window;

# Reading input line-by-line, building hash
my $input_lines = {}; # Hash with all the details
my $fields = []; # array with the fields of interets, in the proper order for printing data.

# Reading from file or STDIN
while (my $line = <>){

    $line =~ s/\s//g; # Removing any whitespace
    $input_lines->{$.}->{"input"} = $line;
}

# Report after reading input:
printf STDERR "[Info] Number of queried variations: %s\n", scalar(keys %{$input_lines});

# The first step of the analyis. Builds a proper hash of all variants in the input
($input_lines, $fields) = BasicInformation::Input_cleaner($input_lines);

# Retrieve information of overlapping gene:
($input_lines, $fields) = GetGene::Gene($input_lines, $fields);

# Retrieve information of protein expressed from overlapping gene:
($input_lines, $fields) = GetProtein::Protein($input_lines, $fields);

# Retieve variant data:
($input_lines, $fields) = GetConsequence::Consequence($input_lines, $fields);

# Fetch variant frequencies where available:
($input_lines, $fields) = GetMAFs::MAFs($input_lines, $fields);

# Run a GWAS test:
($input_lines, $fields) = GWAStest::testGWAScatalog($input_lines, $window, $fields);

# Run GWAVA only if the user wants to:
($input_lines, $fields) = GetGWAVA::GetGWAVA($input_lines, $window, $fields) if $gwava;

##
## Then we have to save the results into a file....
##
$" = $delimiter;
$" = eval '"' . $delimiter . '"' if $delimiter ne ",";

# Processing header fields:
my @array = ();
foreach my $category (@{$fields}){

    my $field = $category;

    # Removing quotes from fied:
    $field =~ s/["']//g;

    # if the field contains the delimiter string it will be quoted:
    if ($field =~ /$"/ or $field =~ / /) {
        $field = '"'.$field.'"';
    }

    # Adding field to the array:
    push (@array, $field);
}

print "@array\n";

# Processing data fields:
for (my $index = 1; $index <= scalar(keys %{$input_lines}); $index++){

    my $stuff = $input_lines->{$index};
    my @array = ();

    # Looping through all fieds in all entries:
    foreach my $field (@{$fields}){
        # Picking the field:
        my $added_field =$stuff->{$field};

        # Removing quotes from field:
        $added_field =~ s/["']//g;

        # if the field contains the delimiter string it will be quoted:
        if ($added_field =~ /$"/ or $added_field =~ / /) {
            $added_field = '"'.$added_field.'"';
        }

        # Adding field to the array:
        push (@array, $added_field);
    }

    print "@array\n";


}
