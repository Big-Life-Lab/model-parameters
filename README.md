# model-export-template (IN PROGRESS)
This repo provides a template for required model export documents. The goal of a model export format is to outline all the steps to go from the starting variables in the model to calculating the outcome of the model.

# Model Export Files

## variables.csv

The *variables* file gives a summary of all the starting variables used in the model. A brief description of its columns are as follows:

* **variable**: name of the start variable (NOTE: THIS DESCRIPTION VARIES B/W DOCUMENTS. OTHER DESCRIPTION = "name of the final transformed variable; allowable variable name in SAS, R, JS, TS, Python, Stata")
* **role**: variable's role in the algorithm development, validation, deployment, KTE process (THIS IS NOT IN THE CURRENT TEMPLATE, INCLUDE?)
* **label**: short variable label, less than 15 characters
* **labelLong**: descriptive variable label
* **section**: major heading used to classify the variable
* **subject**: section sub-heading used to further classify the variable
* **typeEnd**: allowable variable types: cat (categorical), cont (continuous)
* **units**: unit of measurement for the variable (THIS IS INCLUDED IN SOME DESCRIPTIONS OF THE VARIABLES DOCUMENT BUT NOT INCLUDED IN THE MODEL-EXPORT.RMD - INCLUDE?)
* **description**: additional metadata about the variable (THIS IS IN THE CURRENT TEMPLATE, HOWEVER, THE FOLLOWING FIELDS ARE NOT AND, IF THE DECISION IS TO INCLUDE THEM, THEN SUGGEST THIS FIELD BE REMOVED)
* **reference**: reference group (level): TRUE, FALSE, NA
* **center**: indicates variable transformation of center to mean: TRUE, FALSE (missing treated as false)
* **spline**: indicates spline transformation: TRUE, FALSE, NA
* **min**: minimum value for algorithm development
* **max**: maximum value for algorithm development
* **mean**:
* **stdDev**:
* **median**:
* **q1**:
* **q3**:
* **interaction**: indicates variable transformation to interaction variable; value, indicated by interactionIndex column, interation1, interaction2, etc. (label is variables separated by _X_ e.g.,variable1_X_variable2)
* **interactionIndex**: indicates index value (e.g., 1,2,3...) of interaction variable (i.e., interation1, interaction2, interaction3...)
* **dummy**: indicates dummy variable employed: TRUE, FALSE, NA
* **impute**: indicates variable data cleaning from missing imputed values, value is imputed method (e.g., Hmisc-impute)
* **invalid**: indicates method for treating invalid input values (INCLUDE HERE OR SEPARATED CSV FILE)
* **log**: indicates log transformation: TRUE, FALSE, NA
* **outlierMax**: method used with `max`: delete, NA (missing), N/A (not applicable), number (real number) (INCLUDE HERE OR SEPARATED CSV FILE)
* **outlierMin**: method used with `min`: delete, NA (missing), N/A (not applicable), number (real number) (INCLUDE HERE OR SEPARATED CSV FILE)
* **recommended**: variable that is recommended user input: TRUE, FALSE
* **required**: mandatory variable required for scoring the algorithm (i.e, can not be missing and replaced with centered value): TRUE, FALSE

## variable-details.csv

The *variables details* file should include all the variables defined in the *variables* file, giving more information about each of them (e.g., for continuous variables it gives the range of valid values and for categorical variables it lists all their levels). A brief description of its columns are as follows:

* **variable**: The name of the variable. Should correspond to a value in the variable column of the *variables* file.
* **dummyVariable**: The name of the dummy variable created for this variable for the catValue specified. E.g., for sex in the file above, sex_cat1 will have a value of 1 if sex is "m" or 0 otherwise. Similarly, sex_cat2 will have a value of 1 of sex is "f" or 0 otherwise. This column is only used for categorical variables.
* **numValidCat**: The number of valid categories for categorical variables.
* **catLabel**: A label for the level of the categorical variable in that row.
* **catLabelLong**: A more detailed label for each level of the categorical variable
* **catValue**: The value for the level of the categorical variable
* **units**: Unit of measurement for the variable
* **variableType**: Same as the type column in the variables file
* **interval**: The valid range for this variable. Follows the mathematical notation for intervals https://en.wikipedia.org/wiki/Interval_(mathematics).
* **notes**: Any additional metadata about the variable

## model-steps.csv

The *model steps* file documents the steps to go from the start variables to the model output as well as the names of the files with additional information to implement the steps. A brief description of its columns are as follows:

* **step**: name of the step: see valid steps. Valid values: center, rcs, interactions, cox, dummy (note: no file is needed for this step. All dummy variables created need to be documented in the *variables details* file). 
* **fileName**: name of the file which documents additional information needed to implement the step (e.g., center.csv for centering)
* **notes**: for documentation/metadata purpose and does not have any bearing in how the model is run.

## center.csv

* **variable**: name of the variable to center
* **centerValue**: value to use for centering
* **centeredVariable**: name of the new centered variable

## rcs.csv

* **variable**: name of the variable to convert
* **rcsVariables**: names of the new variables created, seperated by a semicolon
* **knots** knots to use, seperated by a semicolon

## interactions.csv

* **interactingVariables**: The list of variables that interact, seperated by a semicolon
* **interactionVariable**: The name of the interaction variable

## cox.csv

* **variable**: The name of the variable
* **coefficient**: The coefficient for this variable
