# VarAnnot

### Description

This script was written to provide high-throughput annotation for variations.
The script returns information from various sources and outputs a table with
each queried variations in each line.

### Version

**v.1.3** Last modified 2015.12.21

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
