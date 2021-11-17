# Descriptive files

There are the following descriptive files

* **descriptive-statistics.csv**: a description of your study cohort (e.g., Table 1)
* **descriptive-lookup.csv**: a reference file used to group results into a bin or category (if applicable)
* **descriptive-bins.csv**: a reference file for results (if applicable)

## descriptive-statistics.csv

* **index**: a column used to quickly locate data without having to search every row in a database table every time a database table is accessed
* **variable**: name of the variable to describe (i.e., the rows in your table 1)
* **catValue**: the variable category (if applicable)
* **groupBy_1**: the variable to group your results by (i.e., the columns in your table 1)
* **groupByValue_1**: the groupBy variable category
* **n**: number of observations
* **proportion**: proportion of observations
* **median**: the observed median value (50th percentile)
* **percentile25**: the observed value for the 25th percentile
* **percentile75**: the observed value for the 75th percentile

Note 1: you can add as many groupBy variables as you want (e.g., ... groupBy_2, groupByValue_2, groupBy_3, groupByValue_3, etc)

Note 2: you could report percent instead of proportion

Note 3: you can change percentile columns based on what you want to report (e.g., if you report the 95% CI change the columns to percentile5 and percentile95)


## descriptive-lookup.csv

* **index**: a column used to quickly locate data without having to search every row in a database table every time a database table is accessed
* **variable**: name of the variable to describe
* **catValue**: the variable category (if applicable)
* **Range**: the range for a calculated value to fall within a category. List both the minimum and maximum value using inclusive [] or exclusive () brackets. 

## descriptive-bins.csv

* **index**: a column used to quickly locate data without having to search every row in a database table every time a database table is accessed
* **variable**: name of the variable to describe
* **catValue**: the variable category (if applicable)
* **percentile**: a new column for each percentile (100-1)

