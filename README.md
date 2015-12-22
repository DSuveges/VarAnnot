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
