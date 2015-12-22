# VarAnnot

### Description

This script was written to provide high-throughput annotation for variations.
The script returns information from various sources and outputs a table with
each queried variations in each line.

### Version

**v.1.3** Last modified 2015.12.21

***

### Requirements

* Working internet connection
* The script uses the following perl packages: **HTTP::tiny**, **POSIX**, **JSON**, **Data::Dumper**
* External programs in path: **bedtools**, **GWAVA**

### Usage

#### Reading input from file:

```bash
perl VarAnnot.pl -g -d <Delimiter> -w <Window>  <Input_file>
```

#### Reading input from pipe

```bash
cat <Input_file> | perl VarAnnot.pl -g -d <Delimiter> -w <Window>
```

#### Parameters
* **-g**

   g is switch, does not takes an argument. When provided, GWAVA score will also be calculated for each variations.
(By default, GWAVA calculation is turned off for faster run)

* **-d**

   Output field delimiter is an optional parameter, it's default value is **,**. User specified delimiter
can be any string. If a field contains the provided delimiter, the filed will be double quoted.
A safe choice for delimitter is tab: "\t" which is easy to parse with perl, awk or other command line tools.

* **-w**

   Window length specifies the distance within any known GWAS signals will be reported.
It's an B<optional> parameter, its default value is B<500000bp>. Provide just the
distances in basepairs without the bp notation. If non-regular window length is
specified, the default value will be used.

* **input_file**

   If no file is given, the script will expect input from the standard input. In the file, the
list of variations are expected to be separated by a newline characher. For the input format see input section.

#### Input

The script accepts a list of variations where each variation is in a new line.
If there are more variations in one line, only the first will be considered!
Variations can be defined by their *rsID* or *SNP ID*.

The preferred format: `chr{chr}:{start}-{end}_{a1}_{a2}`
Where either a1 or a2 has to mach the reference sequence. In there is no match,
a1 will be used as reference, and a2 as alternative.

SNP ID (`chr{chr}:{pos}`) is also accepted, in this case the alternative allele can not
be calculated, and only overlapping rsIDs will returned, but exact matches can not be established.

#### Output

As the script proceeds, many status updates are printed to the standard error.
Then output is printed to standard output. Where the first row is a header with
all field names, then each queried variations are in a separate line.

If there are known gwas signals within the specified distance, a formatted table
is saved to a separated file: `./gwas_signals.tsv`

#### Contact

With questions and problems please contact me: ds26@sanger.ac.uk

#### Output fields

| Field number | Field name | Description |
|---|---|---|
| 0 | input | User input |
| 1 | chr | Chromosome |
| 2 | start | Start  position |
| 3 | end | End  position |
| 4 | matching_rsID | Known variation with matchin alleles |
| 5 | overlapping_rsID | All known variations overlapping the queried position |
| 6 | ref | Reference allele at the queried position |
| 7 | alt | Alternative allele of the variation |
| 8 | ancestral_allele | Ancestral alle is not necessarely the same as the reference allele.  |
| 9 | var_class | Type if variation eg. SNP or INDEL |
| 10 | Gene_name | Name of overlapping gene |
| 11 | Gene_id | Stable Ensembl ID of the overlapping gene |
| 12 | Gene_description | Description of the overlapping gene from Ensebl |
| 13 | Gene_biotype | Biotype (eg. protein coding, lncRNA or antisense) |
| 14 | Gene_strand | Indicating which is the coding strand of the DNA  |
| 15 | Closest_gene-name | Name of the closest gene regardless its biotype |
| 16 | Closest_gene-ID | Ensembl ID of the closest gene |
| 17 | Closest_gene-distance | Distance from the closest gene |
| 18 | Closest_protein_coding_gene-name | Name of the closest protein coding gene |
| 19 | Closest_protein_coding_gene-ID | Ensembl ID of the closest protein coding gene |
| 20 | Closest_protein_coding_gene-distance | Distance from the closest protein coding gene |
| 21 | Protein_Ensembl_ID |  |
| 22 | Transcript_Ensembl_ID |  |
| 23 | Uniprot_ID |  |
| 24 | Uniprot_Name |  |
| 25 | Uniprot_Function |  |
| 26 | Uniprot_Disease |  |
| 27 | Uniprot_Subunit |  |
| 28 | Uniprot_Phenotype |  |
| 29 | Uniprot_localization |  |
| 30 | Uniprot_Tissue |  |
| 31 | Uniprot_Development |  |
| 32 | Variant_Consequence |  |
| 33 | Variant_Impact |  |
| 34 | Variant_Polyphen |  |
| 35 | Variant_PolyphenScore |  |
| 36 | Variant_SiftScore |  |
| 37 | Variant_Codons |  |
| 38 | Variant_AminoAcids |  |
| 39 | Variant_ProteinPosition |  |
| 40 | Variant_Freq_CEU |  |
| 41 | Variant_Freq_TSI |  |
| 42 | Variant_Freq_FIN |  |
| 43 | Variant_Freq_GBR |  |
| 44 | Variant_Freq_IBS |  |
| 45 | GWAS_hits |  |
| 46 | GWAVA_score |  |
| 47 | avg_gerp |  |
| 48 | gerp |  |
| 49 | DNase |  |
| 50 | dnase_fps |  |
| 51 | bound_motifs |  |
