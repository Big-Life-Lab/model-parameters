This template repository provides a starting point when making a model export repository for a new model. In short, a model export is a set of files that togther are used to implement the model in certain contexts. The full documentation can be seen [here](https://github.com/Big-Life-Lab/bllflow/blob/master/assets/specs/model-csv-to-pmml/model-csv-to-pmml-spec.Rmd). 

Each branch in this repository provides a starting point for a different type of model. Look [here](#Branches) for the list of branches and the models they're for.

# Usage

1. Create a new GitHub repository
2. In the "Repository template" section, select the **Big-Life-Lab/model-export-template** option
3. Delete all branches except for the one which best represents your model
4. Rename the selected branch to **main**

# Branches

* **fine-and-gray-template**: Export files for a fine and gray model 
* **logistic-regression-template**: Export files for a logistic regression model

# Fine and gray Model

The current branch provides a starting point for fine and gray models. The files in the `model-export` folder are used to represent a fine and gray model to predict the risk developing diabetes in 5 years. The model has three variables:

1. **Sex**: A two category variable representing the sex of an individual
2. **Age**: The age of an individual in years
3. **BMI**: The BMI of an individual in kg/m^2

The files also provide the following information:

1. How to map the variables from a database called `context` onto the starting variables for the model
2. How to transform the model variables into the final variables for the model
3. The beta coefficients and baseline hazard values for calculating a risk score

## Files

### /model-export

* **variables.csv**: The list of variables in the model and their descriptions.
* **variables-details.csv**: Rules for mapping variables in various databases to the variables in the model.
* **model-export.csv**: The location of the various files needed for implementation.

#### /model-export/model-steps

* **model-steps.csv**: The steps for transforming the model start variables into the final variables for the model as well as how to calculate the final risk score.
* **dummy.csv**: Rules for the dummying categorical variables
* **center.csv**: Rules for centering variables
* **rcs.csv**: Rules for converting certain continuous variables into restricted cubic splines
* **interaction.csv**: Rules for creating interaction variables
* **beta-coefficients.csv**: The beta coefficients for the fine and gray model
* **baseline-hazards.csv**: The baseline hazard values for the fine and gray model 

### /derived-vars

* **bmi_cont.fun**: The function to run when creating the **BMi** derived variable