# Data Validation

## Introduction

When it comes time to integrate or implement an algorithm in a setting (EMR system, online tool, mobile application etc.), there are several data processing steps that may need to be done during the algorithm scoring process. One of these steps involves ensuring that the data coming from an implementation setting is valid before it can be used to score an algorithm. For example, if an algorithm has age as a covariate which has a valid range between 21 and 80, the implementation setting needs to flag rows with age values outside of this range as invalid. In addition, decisions need to be made and documented on how to deal with invalid values. For example, if age is invalid, should the algorithm scoring process be stopped? or do we move on but replace the invalid value with a valid one such as the population mean? 

The goal of the validation CSV file is to be the single source of truth for these data validation questions for an algorithm. In addition, the validation CSV file is meant to be a standard that will accomodate the data validation needs for all algorithms that need to be implemented. Finally, it will be machine actionable, meaning that a computer program should be able to read a validation CSV file and implement its rules on a dataset.

This document is meant to be the single source of truth for the validation CSV file. It will go over the different validation features currently supported by the file, how to represent each feature in the file and a summary of all the columns in the file.

## Validation CSV File Overview

The validation CSV file is a CSV file that specifies the validation rules for the variables in an algorithm. Each row in the CSV file specifies a validation rule to apply to a variable as well as what to do when validation fails. Altogether the columns in the file specify:

* The name of the variable to validate
* The validation rule to apply to a variable
* The value to use for the specified validation rule
* What to do when the validation rule fails

## Validation Features

### Specifying the name of the variable to validate

This is done using the `variable` column. For example,

| variable |
|----------|
| age      |
| sex      |

The above validation CSV table has two rows, one to specify the validation rules for the age variable and one row for the sex variable.

### Specifying the validation rule to apply to the variable and its value

This is done using the `rule` and `value` column. All the currently supported rules are described in the following sections

#### Validating the data type of a variable

This is done by using the `type` keyword in the `rule` column. The allowed values are:

| Type Value | Description                                                                                                           |
|------------|-----------------------------------------------------------------------------------------------------------------------|
| number     | Use when the variable value should be a number such as a deciaml or an integer                                        |
| string     | Use when the variable value should be a string such as a categorical sex variable with categories "male" and "female" |

For example,

| variable | rule   | value  |
|----------|--------|--------|
| age      | type   | number |
| sex      | type   | string |

In the above validation CSV table,

* The age variable is a `number` type
* The sex variable is a `string` type

#### Validating the allowed range(s) for a number variable

This is done using the `range` keyword in the `rule` column.  We use the mathematical notation to define an [interval](<https://en.wikipedia.org/wiki/Interval_(mathematics)>). Examples are:

- [1, 2]: All values between 1 and 2, inclusive of 1 and 2 are considered valid
- (1, 2]: All values between 1 and 2, only inclusive of 2 are considered valid
- [1, 2): All values between 1 and 2, only inclusive of 1 are considered valid
- (1, 2): All values between 1 and 2, excluding 1 and 2 are considered valid
- [Inf, 1]: All values between negative infinity and 1, including 1 are considered valid
- [1, Inf]: All values between 1 and positive infinity, including 1 are considered valid

The **Inf** keyword can be used to specify infinity either as the lower or upper bound.

For example,

| variable | rule   | value   |
|----------|--------|---------|
| age      | range  | [20,81] |

In the above example,

* The age variable has a valid range between 20 and 81, inclusive of its endpoints
* The sex variable is a string and adding a range rule would not make sense

#### Validating the allowed values for a string variable

This is done using the `allowed` keyword in the `rule` column. It is mainly used when specifying the allowed category values for a categorical variable. Each allowed value should be seperated by a semi-colon. For example,

| variable | rule    | value        |
|----------|---------|--------------|    
| sex      | allowed | male;female  |

In the above example,

* The sex variable is only allowed to have one of two values: male or female. These values are case-sensitive.
* The age variable is a variable and adding an allowed rule would not make sense

#### Whether a missing value in a variable is allowed or not

This is done using the `nullable` keyword in the `rule` column. It can have one of two values, TRUE or FALSE, to specify that missing values are allowed and the opposite respectively. For example,

| variable | rule     | value   |
|----------|----------|---------|   
| age      | nullable | FALSE   |
| sex      | nullable | TRUE    |

In the above example, the age variable cannot have a missing value while the sex variable can.

### Specifying how to handle failed validations

This is done using the `error_handle` column. The allowed values are:

| Value    | Description                                                                                                                                                                                                                                      |
|----------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| error    | Stop the algorithm scoring process                                                                                                                                                                                                               |
| warning  | Log a warning but continue the algorithm scoring process                                                                                                                                                                                         |
| truncate | Only valid for number type variables. Replaces the invalid value with one of its range limits. If the value is above the upper limit, it will be set to the upper limit. If the value is below the lower limit, it will be set to the lower limit    |

When handling a validation rule failure, there may be certain situations where the invalid value should be replaced with another valid value. This can be done using the `error_replace` column. This column can be a any value but will only be used when the `error_handle` column's value is **warning**

For example,

| variable | rule     | value        | error_handle | error_replace |
|----------|----------|--------------|--------------|---------------|
| age      | type     | number       | error        |               |
| age      | range    | [20,81]      | truncate     |               |
| age      | nullable | FALSE        | error        |               |
| sex      | type     | string       | error        |               |
| sex      | allowed  | male;female  | error        |               |
| sex      | nullable | FALSE        | warning      | male          | 

In the above example,

* For the age variable, if its not a number or if its missing, then the process should throw an error and stop. However, if the valuie is a number and not in the valid range, it will be truncated to either the maximum and minimum range.
* For the sex variable, if its not a string or if it is a string but its not one of its allowed values, then the process should throw an error and stop. However, if the value is missing, it should log a warning and replace the missing value with **male**.

### Specifying where a validation rule can be used

There may be situations where the validation rule for a variable is different depending on the setting in which the rule is implemented, this is done using the `location` column. The value can be any string value identifying the location in which it is valid. For example,

| variable | rule     | value        | error_handle | error_replace   | location |
|----------|----------|--------------|--------------|-----------------|----------|
| age      | type     | number       | error        |                 | all      |
| age      | range    | [20,81]      | truncate     |                 | all      |
| age      | nullable | FALSE        | error        |                 | all      |
| sex      | type     | string       | error        |                 | all      |
| sex      | allowed  | male;female  | error        |                 | all      |
| sex      | nullable | FALSE        | warning      | male            | EMR_1    |
| sex      | nullable | FALSE        | warning      | female          | EMR_2    |

In the above example,

* The validation rule for age should be used in all settings. This can also be communicated by leaving the column value empty.
* All validation rules for sex should be used in all settings except for **nullable**. In the EMR_1 system, if sex is missing then it will be replaced with **male** whereas in EMR_2, if sex is missing then it will be replaced with **female**.



