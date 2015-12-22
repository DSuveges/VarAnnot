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

#### Reading input from pipe:

```bash
cat <Input_file> | perl VarAnnot.pl -g -d <Delimiter> -w <Window>
```

#### Parameters:
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

* **input_file*

   If no file is given, the script will expect input from the standard input. In the file, the list of variations are expected to be separated by a newline characher.
For the input format see input section. 
