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
column in the `category-set.csv` file and the `fileDesc` column in the
`file-metadata.csv` file.

When the data type for a value is an array i.e. it needs to encode multiple
values, a colon (;) should be used as the separator, for example, `a;b`. The
`algorithmType` column in the `file-metadata.csv` file and the `categorySet`
column in the `column-metadata.csv` file use this format.

## Category Sets

Categorical columns have a fixed set of allowed values called a
**category set**. All category sets are defined in the `category-set.csv` file.

Each row in this file defines a category using the following columns:

- `categorySet`: The name of the category set that the category is part of;
- `columnValue`: The category value; and
- `desc`: The human readable description of the category.

A category column then references its set(s) by name through the
`categorySet` column in `column-metadata.csv`.

Multiple categorical columns that have the same category values and
descriptions should reuse the same category set. For example, the
`variable-type` set defines the `cat` and `cont` values once, and every column
that accepts those values (such as `typeEnd` and the various `*VariableType`
columns) references it. Conversely, columns that share a value but give it a
different meaning (e.g., the `N/A` in `model-steps's` `fileType` versus
`type-start-na`) should keep separate sets so each keeps its own description.

A `categorySet` value may list more than one set, separated by a semi-colon, in
which case the column accepts the union of those sets' values. For example,
`variable-type;type-start-na` allows `cat`, `cont`, and `N/A`.

## New Algorithms

When adding a newly supported algorithm to the repository, make sure to update
the `algorithmType` column in the `file-metadata.csv` appropriately. This
column is used to specify which algorithm(s) each file is applicable to. Use a
value of `all` if a file is applicable to all algorithms.
