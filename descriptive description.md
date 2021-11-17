# Descriptive files

There are the following descriptive files

* **descriptive-statistics.csv**: Table 1 a description of your study cohort
* **descriptive-lookup.csv**: a reference file used to group results into a bin or category (if applicable)
* **descriptive-bins.csv** a reference file for results (if applicable)

## descriptive-statistics.csv

* **variable**: name of the variable to describe (i.e., the rows in your table 1)
* **catValue**: the variable category (if applicable)
* **groupBy_1**: the variable to group your results by (i.e., the columns in your table 1)
* **groupByValue_1**: the groupBy variable category
* **n**: number of observations
* **proportion**: proportion of observations (could have **percent** column instead)
** **median**: median value
* **percentile25**: 
* **percentile75**:

- Note 1: you can add as many groupBy variables as you want (e.g., ... groupBy_2, groupByValue_2, groupBy_3, groupByValue_3, etc )

- Note 2: Change percentile columns based on your reporting values (e.g., if you report the 95% CI change the columns to percentile5 and percentile95)

## descriptive-lookup.csv

* **variable**: name of the variable to describe
* **CatValue**: the variable category
* **Range**: the range for a calculated value to fall within a category. List both the minimum and maximum value using inclusive [] or exclusive () brackets. 

## descriptive-bins.csv

* **variable**: name of the variable to describe
* **catValue**: the variable category (if applicable)
* **percentile**: a new column for each percentile (100-1)

