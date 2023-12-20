# nf-gas-nomenclature

A simple pipeline for assigning cluster codes to samples, utilizing existing cluster definitions.

## Requirements

- Container software (docker, singularity, apptainer, gitpod, wave, charliecloud etc.)
- Nextflow runtime

## Basic Usage

```
nextflow run --input {PATH/TO/INPUT_SHEET.csv} --outdir {OUTPUT_DIRECTORY_LOCATION} -profile {singularity/docker}
```


## Input Sheet

The pipeline requires a csv file for input with the following items. To generate cluster definitions you will have to run the [nf-gas-clustering pipeline](https://github.com/phac-nml/nf-gas-clustering) first.

|sample|query|reference|clusters|
|-------|-------|-------|-------|
|sample_name|/path/to/query/allele_calls/|/path/to/reference_allele_matrix|/existing/cluster/defintions|


