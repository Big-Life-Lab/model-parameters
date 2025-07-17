The CSV files in this folder contains metadata for the different model
parameter files, for example the types of files, their columns, their types
etc.

## Metadata Columns 

Use camel case for metadata columns. For example, `fileName`, `columnName`, and
`columnValue`.

## Metadata Column Values

Use kebab case for metadata column values, for example, `simple-model`,
`beta-coefficients`, and `model-export`. An exception is the `columnName`
metadata column whose values should be camel case. In addition, human friendly
language should be used for free form text metadata columns like descriptions
and labels should be written in a human readable way, for example, the `desc`
column in the `column-category.csv` file and the `fileDesc` column in the
`file-metadata.csv` file.

When the data type for a value is an array i.e. it needs to encode multiple
values, a colon (;) should be used as the separator, for example, `a;b`. The
`algorithmType` column in the `file-metadata.csv` file uses this format.
