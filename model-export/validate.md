# Validation specifications

## Validation processes

1. **order**- The order of execution of the validation, if validating an entire data set. Validation for some items may need to occur before other items.
1. **location**- There are several different locations where variables are validated. Items include: web-based questionnaire, data set, etc.
1. **platform**- Validation may differ depending on the platform. NA or blank if not required.
1. **language**- The implementation process should support different programming languages if required. For example, the Excel templates will include data validation where possible. However, not all validation steps can be included in Excel, and data validation occurs in multiple steps. Therefore, all validation steps are also able to be executed in Python.
1. **description**- Each validation step should include a clear human-readable description in English and French.
1. **required**- Validation should indicate whether a variable is required.
1. **dependencies**- Whether there are dependencies on other variables or validation steps, in addition to the order of validation.
1. **warning**- The number and type of warnings should be presented in human-readable form. Warnings should be presented in different formats, platforms, programs, etc.
1. **errors**- The number and type of errors should be presented in human-readable form. Errors should be presented in different formats, platforms, programs, etc.
1. **normalization (transformation)**- iI values can be transformed, then this should occur. For example, data submitted with a non-SI unit (e.g., liters/hour) could be converted to its SI equivalent (m3/s) Variable mapping should be considered during variable mapping and not during validation, despite recognizing that mapping could be performed using normalization methods.
1. **coercion**- If values can be coerced, then this should happen. i.e. integer as text should be coerced to numbers and a warning issued that this occurred.
1. **version-specific**- Validation should indicate what version of the algorithm the step is applicable for. Provisions for coercion and/or transforming old versions variables, types, and coercion of values to the most recent version. Warnings and errors should be issued, as appropriate.

## Validation schema and rules

A validation schema is a set of rules or validation dictionaries. The list of validation rules below is drawn from the Cerberus Python validation library.

By defining a validation schema for the ODM, we will be able to create and maintain a consistent universal data entry format.

- _allow_unknown_ - allow variables that are not defined in the validation schema.

- _allowed_ - define a set of items within the validation schema which will allow the user to pre-approve a specific list of items. If the input exists within the allowable list, then no errors should arise after entering the data. If an entry is not within the predefined list, an error will be thrown, showing the user the “unallowed” value. Instances of this function could be applied to all categories in `variableCategory.csv`.

- _allof_ - if an entry has dependencies that need to be met, this would verify all it’s conditions prior to output whether it is acceptable. If all conditions have not been fulfilled, the user will be notified where the error is located, and then can be changed appropriately. Examples include:applied to specifying character limits for the “notes” in the ODM.

- _anyof_ - if an entry has some conditions which need to be met, then the entry can be validated. If a certain number of conditions have not been verified, the user will be shown where the error lies, and can be amended if necessary. Examples of this implementation would be if the user has correctly inputted the site where wastewater sample has been collected (type-variable) and is able to leave the “typeOther” variable empty for this table.

- _check_with_ - validates the entry by its ability to call other functions. If the data is not valid under the criteria of the external function, then the user will receive an error message specifying the issue. An example of this function validing an email address.

- _contains_ - is used to verify if there are any missing entries within the document. Compare the schema and the file to determine if the entries contain all the necessary items. If the document does not contain the necessary items, then a user will be prompted with an error to ensure all entries are filled/contain the correct inputs. This could be applied to scanning whether the inputted email address contains the “@” character.

- _dependencies_ - if adequate mapping is provided in the schema, dependencies are extremely useful when trying to ensure that entries/inputs are in the correct format/and are within the bounds in the prespecified rules. If the input does not satisfy all the parameters, an error will be reflected to the user indicating that the field depends on other values, meaning that they may need to be modified.

- _empty_ - used to specify whether an entry is mandatory. If set to false, then the parameter must be filled. An error detailed that this variable is not allowed to be empty will be thrown to the user. Examples of this implementation within the ODM can be seen through variables such as “typeOther” where if “type” has an input, typeOther can remain empty.

- _excludes_ - allows for specific variables when defined in the schema to ignore other fields. A use case would arise if variables overlapped within the ODM.

- _forbidden_ - allows specific criteria defined within the schema to be excluded from the data. If an input is within the pre-defined forbidden list for a certain variable, the user will receive an error specifying that the item is forbidden. As the model is evolving, this could be used to filter out dated inputs, such as inputting a date prior to 2020-01-01.

- _items_ - creates a list of items whose size depends on the amount of allowed predefined entries. Each index within the list has a pre-specified data-type which must match the input. When a list is inputted, each entry within the list is cross-referenced to determine if all data types are in the appropriate format. If a list of only “characters” is desired, this implementation could be used.

- _keysrules_ - takes a list of key,value pairs with their desired data type. The input must match the definitions within the schema. If the correct data types are not inputted, then the user will receive error warnings to change the datatype.

- _min, max_ - specifies the minimum and maximum range of values for an input. This function is designed for floats, doubles or integers, and can be used to set boundaries for variables within the ODM (eg: geoLong/geoLat).

- _minlength, maxlength_ - specifies the minimum and maximum values for lists.

- _noneof_ - returns an error if all entries do not meet any of the criteria.

- _nullable_ - specifies whether an entry is allowed to be blank. This would be implemented for variables such as “typeOther” which can be blank under the correct circumstances.

- _oneof_ - if the entries fulfills exactly one of the specifications in the schema, then the input will be validated.

- _regex_ - this function validates only string values which match the pre-specified format in the schema. This can be extremely useful when trying to validate email addresses, and ensure they are in the correct format

- _required_ - used to specify whether a variable requires an entry.

- _schema (dict)_ - defining the validation rules in a key-value format.

- _schema (list)_ - defining the validation rules in a list format.

- _type_ - the data types allowed for the key values.

- _valuesrules_ - validates the key.

## Validation warnings and errors

Warnings are returned to a user when the data does not conform to a validation rule but the data can either be coerced or normalized to the specified rule or the deviation is not a requirement for ODM compliant data. Whenever possible, warnings will be used instead of errors. For example, a warning is issued when:

- The variable type is an integer, but the value is a text that can be coerced to an integer. i.e. “1” → 1.
- The text length exceeds maximum allowable, in which case it will be truncated to the maximum length.

Errors are returned to a user when the data does not conform to a validation rule and the data cannot be coerced or normalized to the specified rule. An example is required data that is missing.

Both warnings and errors will include a message that includes:
Why the warning or error occurred.
How to correct the warning or error.

## Normalization or transformation

Normalization is the process of modifying data. If the dataset is not in the desired “long” format, a transformation function will be applied to reformat the table which can then be validated using the appropriate rules/specifications. If data types are not in the correct format, then data-types will be converted into the correct data types, as reflected in the validation schema. If there is any missing data, then warnings will be sent to the user, to rectify this issue.
