# model-export-template (IN PROGRESS)
This repo provides a template for required model export documents. The goal of a model export format is to outline all the steps to go from the starting variables in the model to calculating the outcome of the model.

# Model Export Files

## variables.csv

The *variables* file gives a summary of all the starting variables used in the model. A brief description of its columns are as follows:

* **variable**: Name of the start variable
* **label**: A short variable label, less than 15 characters
* **labelLong**: A descriptive variable label
* **section**: Major heading used to classify the variable
* **subject**: Section sub-heading used to further classify the variable
* **typeEnd**: Allowable variable types: cat (categorical), cont (continuous)
* **description**: Additional metadata about the variable

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

## Model Steps

The *model steps* file documents the steps to go from the start variables to the model output as well as the names of the files with additional information to implement the steps. A brief description of its columns are as follows:

* **step**: The name of the step. The value of this column should match up with one of the valid steps values outlined below. 
* **fileName**: The name of the file which documents additional information needed to implement the step. E.g., the center step file, center.csv, would need to document the variables being centered along with their centering value. The steps documentation gives more information as to the structure of the file needed for each step.
* **notes**: This column is for documentation/metadata purpose and does not have any bearing in how the model is run.

## Steps

This section documents all the supported steps. The keyword highlights what phrase should be used to represent this step in the *model steps* file.

### center

Keyword: center

Columns:

* **variable**: The name of the variable to center
* **centerValue**: The value to use for centering
* **centeredVariable**: The name of the new centered variable

### RCS

Keyword: rcs

Columns:

* **variable**: The name of the variable to convert
* **rcsVariables**: The names of the new variables created, seperated by a semicolon
* **knots** The knots to use, seperated by a semicolon

An example file is shown below

```{r}
eg_rcs_step <- read.csv(file.path(getwd(), "/assets/model-export/rcs.csv"))
DT::datatable(eg_rcs_step)
```

### Dummy

Keyword: dummy

No file is needed for this step. All dummy variables created need to be documented in the *variables details* file.

### Interactions

Keyword: interaction

Columns:

* **interactingVariables**: The list of variables that interact, seperated by a semicolon
* **interactionVariable**: The name of the interaction variable

An example file is shown below

```{r}
eg_interactions_step <- read.csv(file.path(getwd(), "/assets/model-export/interactions.csv"))
DT::datatable(eg_interactions_step)
```

The first row in the preceding file says that the interaction variable ageXdiabetes is created by interacting the age and diabetes variable
Similarly the second row says that the interaction variable ageXsmoking is created by interacting the age and smoking variable

### Cox

A step to evaluate a cox survival model. The output of this step will be the risk of getting the outcome event.

Keyword: cox

Columns:

* **variable**: The name of the variable
* **coefficient**: The coefficient for this variable
