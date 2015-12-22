# VarAnnot

### Description

This script was written to provide high-throughput annotation for variations.
The script returns information from various sources and outputs a table with
each queried variations in each line.

**Sources**:

  * Basic variation and gene information: [Ensembl](http://www.ensembl.org/index.html)
  * [1000 Genomes](http://www.1000genomes.org/about#ProjectSamples) minor allele frequency: [Ensembl](http://www.ensembl.org/index.html)
  * Prontein information from [Uniprot](http://www.uniprot.org/)
  * overlapping GWAS signals: [GWAS catalog](https://www.ebi.ac.uk/gwas/) (modified local file, downloaded: 2015.06.16)
  * gene annotations: local [GENCODE](http://www.gencodegenes.org/) file (release v.19)
  * GWAVA score: local [GWAVA](http://www.nature.com/nmeth/journal/v11/n3/full/nmeth.2832.html) run

**About the methods:**

  * Ensembl queries are submitted through the [REST API](http://grch37.rest.ensembl.org/)
  * Used human genome build: **GRCH37**

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

### Input

The script accepts a list of variations where each variation is in a new line.
If there are more variations in one line, only the first will be considered!
Variations can be defined by their *rsID* or *SNP ID*.

The preferred format: `chr{chr}:{start}-{end}_{a1}_{a2}`
Where either a1 or a2 has to mach the reference sequence. In there is no match,
a1 will be used as reference, and a2 as alternative.

SNP ID (`chr{chr}:{pos}`) is also accepted, in this case the alternative allele can not
be calculated, and only overlapping rsIDs will returned, but exact matches can not be established.

### Output

As the script proceeds, many status updates are printed to the standard error.
Then output is printed to standard output. Where the first row is a header with
all field names, then each queried variations are in a separate line.

If there are known gwas signals within the specified distance, a formatted table
is saved to a separated file: `./gwas_signals.tsv`

### Output fields

| Field number | Field name | Description |
|:---:|:---:|:---|
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
| 10 | Gene_name | Name of overlapping gene (if multiple genes are overlapping with the variation, the first one is picked) |
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
| 21 | Protein_Ensembl_ID | If the overlapping gene is protein coding, the Ensembl ID of the coded protein |
| 22 | Transcript_Ensembl_ID | The Ensembl ID of the canonical transcript of the overlapping gene |
| 23 | Uniprot_ID | The Uniprot ID of the protein coded by the overlapping gene |
| 24 | Uniprot_Name | Name of the coded protein |
| 25 | Uniprot_Function | Function of the coded protein |
| 26 | Uniprot_Disease | Disease associated with the coded protein |
| 27 | Uniprot_Subunit | Subunit information of the coded protein |
| 28 | Uniprot_Phenotype | Phenotypes associated with the coded protein |
| 29 | Uniprot_localization | Intracellular localization of the coded protein |
| 30 | Uniprot_Tissue | Tissues where the protein is expressed |
| 31 | Uniprot_Development | Developmental stage where the protein plays a role |
| 32 | Variant_Consequence | Predicted Ensembl consequence |
| 33 | Variant_Impact | Impact of the variation |
| 34 | Variant_Polyphen | Polyphen consequence category |
| 35 | Variant_PolyphenScore | Polyhen score of the amino acid variation |
| 36 | Variant_SiftScore | SIFT score of the amino acid variation |
| 37 | Variant_Codons | Codon change calused by the variation |
| 38 | Variant_AminoAcids | Amino acid change caused by the variation |
| 39 | Variant_ProteinPosition | Protein position where the sequence is changed |
| 40 | Variant_Freq_CEU | MAF in Utah residents with Northern and Western European ancestry (1000 Genomes) |
| 41 | Variant_Freq_TSI | MAF in Toscani in Italia (1000 Genomes) |
| 42 | Variant_Freq_FIN | MAF in Finnish in Finland  (1000 Genomes) |
| 43 | Variant_Freq_GBR | MAF in British in England and Scotland (1000 Genomes) |
| 44 | Variant_Freq_IBS | MAF in Iberian populations in Spain (1000 Genomes) |
| 45 | GWAS_hits | List of GWAS hits within a defined distance around the variation |
| 46 | GWAVA_score | GWAVA functionality prediction (above 0.5 the variation is considered to be functional) |
| 47 | avg_gerp | GERP score averaged for 100 residues around the variation |
| 48 | gerp | GERP score of the variation |
| 49 | DNase | Number of cell types where the site is DNase sensitive |
| 50 | dnase_fps | DNase footprints in cell lines |
| 51 | bound_motifs | Number of motifs bound to this region in various cell types |

### Folders contain

* **/data**

   * `/data/gencode.v19.annotation_20150603_protein_coding_genes_sorted.bed.gz`

     List of known protein coding genes in *.bed* format. GENCODE version: 19. Positions are in GRCH37 build (as well as in all other files).

   * `/data/gencode.v19.annotation_20150603_sorted.bed.gz`

     List of all known genes in *.bed* format. GENCODE version: 19.

   * `/data/gwas_catalog_20150616.bed.gz`

     List of known known GWAS signals in *.bed* format. Downloaded from the GWAS catalog on 2015.06.18 and extended with our positive controls.

* **/packages**

   * `/packages/BasicInformation.pm`

      A set of functions to retrieve the most basic information of the variation regardless the diversity of the accepted inputs.

   * `/packages/GetConsequence.pm`

      Get the most severe predicted consequence based on the remote run of the Variant effect predictor.

   * `/packages/GetGene.pm`

       Returns with the cosest gene and closest protein coding gene and the distances.

   * `/packages/GetMAFs.pm`

       Queries the Ensembl database if the queried variation has 1000 genomes frequencies.

   * `/packages/GetProtein.pm`

       Get protein annotation information if Uniprot cross reference is given.

   * `/packages/GWAStest.pm`

       Checks if there are any gwas signals in around the variation.

   * `/packages/GetGWAVA.pm`

       Runs GWAVA and parses its output.

   * `/packages/RESTsubmit.pm`

       A function to submit properly formulated REST queries.

### Contact

With questions and problems please contact me: ds26@sanger.ac.uk
