# Data Validation

## Introduction

When it comes time to integrate or implement an algorithm in a setting (EMR system, online tool, mobile application etc.), there are several data processing steps that may need to be done before the algoriothm scoring steps. One of these steps involves ensuring that the data coming from an implementation setting is valid before it can be used to score an algorithm. For example, if an algorithm has age as a covariate which has a valid range between 21 and 80, the implementation setting needs to flag rows with age values outside of this range as invalid. In addition, decisions need to be made and documented on how to deal with invalid values. For example, if age is invalid, should the algorithm scoring process be stopped? or do we move on but replace the invalid value with a valid one such as the population mean? 

The goal of the validation CSV file is to be the single source of truth for these data validation questions for an algorithm. In addition, the validation CSV file is meant to be a standard that will accomodate the data validation needs for all algorithms that need to be implemented. Finally, it will be machine actionable, meaning that a computer program should be able to read a validation CSV file and implement its rules on a dataset.

This document is meant to be the single source of truth for the validation CSV file. It will go over the different validation features currently supported by the file, how to represent each feature in the file and a summary of all the columns in the file.

## Validation CSV File Overview

The validation CSV file is a CSV file to specify the validation rules for the variables in an algorithm. Each row in the file specifies the validation rules for a variable in the algorithm. Within each row we can also specify how to handle missing values for a variable as well as what to do when a validation error has occured. Altogether the columns in the file specify:

* The name of the variable to validate
* The validation rules to apply to a variable
* What to do when a missing value is encountered
* What to do when a validation rule has failed

## Validation Features

### Specifying the name of the variable to validate

This is done using the `variable` column. For example,

| variable |
|----------|
| age      |
| sex      |

The above validation CSV table has two rows, one to specify the validation rules for the age variable and one row for the sex variable.

### Validating the type of a variable

This is done using the `type` column. The allowed values are:

| Type Value | Description                                                                                                           |
|------------|-----------------------------------------------------------------------------------------------------------------------|
| number     | Use when the variable value should be a number such as a deciaml or an integer                                        |
| string     | Use when the variable value should be a string such as a categorical sex variable with categories "male" and "female" |

For example,

| variable | type   |
|----------|--------|
| age      | number |
| sex      | string |

In the above validation CSV table,

* The age variable is a `number` type
* The sex variable is a `string` type

### Validating the allowed range for a number variable

This is done using the `range` column.  We use the mathematical notation to define an [interval](<https://en.wikipedia.org/wiki/Interval_(mathematics)>). Examples are:

- [1, 2]: All values between 1 and 2, inclusive of 1 and 2 are considered valid
- (1, 2]: All values between 1 and 2, only inclusive of 2 are considered valid
- [1, 2): All values between 1 and 2, only inclusive of 1 are considered valid
- (1, 2): All values between 1 and 2, excluding 1 and 2 are considered valid
- [Inf, 1]: All values between negative infinity and 1, including 1 are considered valid
- [1, Inf]: All values between 1 and positive infinity, including 1 are considered valid

The **Inf** keyword can be used to specify infinity either as the lower or upper bound.

For example,

| variable | type   | range   |
|----------|--------|---------|
| age      | number | [20,81] |
| sex      | string |         |

In the above example,

* The age variable has a valid range between 20 and 81, inclusive of its endpoints
* The sex variable is a string and thus the range column does not apply to it. Its value is empty for this row.

### Validating the allowed values for a string variable

This is done using the `allowed` column. It is mainly used when specifying the allowed category values for a categorical variable. Each allowed value should be seperated by a semi-colon. For example,

| variable | type   | range   | allowed     |
|----------|--------|---------|-------------|    
| age      | number | [20,81] |             |
| sex      | string |         | male;female |

In the above example,

* The age variable does not have a value for the `allowed` column since its a number and we've already specified its valid range in the `range` column
* The sex variable is only allowed to have one of two values: male or female. These values are case-sensitive.

### Whether a missing value in a variable is allowed or not

This is done using the `nullable` column. It can have one of two values, TRUE or FALSE, to specify that missing values are allowed and the opposite respectively. For example,

| variable | type   | range   | allowed     | nullable |
|----------|--------|---------|-------------|----------|   
| age      | number | [20,81] |             | FALSE    |
| sex      | string |         | male;female | TRUE     |

In the above example, the age variable cannot have a missing value while the sex variable can.

### Specifying a replacement value for a missing value

This is done using the `default_value` column. When missing values are allowed for a variable, that usually means there is a value that the missing value should be replaced with before scoring. For example,

| variable | type   | range   | allowed     | nullable | default_value |
|----------|--------|---------|-------------|----------|---------------|   
| age      | number | [20,81] |             | FALSE    |               |
| sex      | string |         | male;female | TRUE     | male          |

In the above example, 

* The age variable has an empty `default_value` since missing values are not allowed
* The sex variable has its `default_value` set to male, meaning that when sex is missing for a row, it will be replaced with `male`

### Specifying how to handle failed validations

This is done using the `error_handle` column. The allowed values are:

| Value    | Description                                                                                                                                                                                                                                      |
|----------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| error    | Stop the algorithm scoring process                                                                                                                                                                                                               |
| warning  | Log a warning but continue the algorithm scoring process                                                                                                                                                                                         |
| truncate | Only valid for number type variables. Replaces the missing value with one of range limits. If the value is above the upper limit, it will be set to the upper limit. If the value is below the lower limit, it will be set to the lower limit    |

For example,

| variable | type   | range   | allowed     | nullable | default_value | error_handle |
|----------|--------|---------|-------------|----------|---------------|--------------|   
| age      | number | [20,81] |             | FALSE    |               | error        |
| sex      | string |         | male;female | TRUE     | male          | warning      |

In the above example, if the age or sex values for a row are invalid, then that row should not be scored with the algorithm.

### Specifying where a validation rule can be used

There may be situations where the validation rule for a variable is different depending on the setting in which the rule is implemented, this is done using the `location` column. The value can be any string value identifying the location in which it is valid. For example,

| variable | type   | range   | allowed     | nullable | default_value | error_handle | location |
|----------|--------|---------|-------------|----------|---------------|--------------|----------|   
| age      | number | [20,81] |             | FALSE    |               | error        | all      |
| sex      | string |         | male;female | TRUE     | male          | warning      | EMR_1    |
| sex      | string |         | male;female | TRUE     | female        | warning      | EMR_2    |

In the above example,

* The validation rule for age should be used in all settings. This can also be communicated by leaving the column value empty.
* The first validation rule for sex should only be used in the EMR_1 EMR system
* The second validation rule for sex should only be used in the EMR_2 EMR system


