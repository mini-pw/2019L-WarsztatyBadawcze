# Templates

This README contain information about structure of the database, naming convention for files, and structures of files.

Do not use spaces and special characters in file and folder names.

## Structure 

Database of models has the followig nested structure:

- database of models 

  - data set `source_name`
  
      The name of the folder should consists of two parts: source and name of data set.
      E.g.: `openml_liver-disorders`, `kaggle_titanic`
      
      This folder should contain `dataset.json` file.

      - task `task_target`
      
        The name of the folder should consists of two parts: task and target variable.
        E.g. `regression_drinks`, `classification_diabetes`
        
        This folder should contain `task.json` file.

        - model `md5hash`
      
          The name of the folder should be an md5 has of model object.
          E.g. `c1994bdb7ecb3c6f3c8f3b35f4b47f1f`
          
          This folder should contain `model.json`, `audit.json`, `code.R`, and `sessionInfo.txt` files.


## code.R

[Example](code.R)

File should contain 8 main sections: 

* libraries,
* config (eg. seed, api keys),
* data,
* preprocessing (eg. filling missing data, feature transformations),
* model - model and parameters,
* hash:
    - hash of model reated with `digest()` function from the `digest` R package,
    - second line should contain value of the md5 hash,
* audit - measures of performance calculated with 5-fold cross-validation,
* session info - saving information about the session.

Section name should be preceeded by `#:#`
Each section should end with printing results.

Code should be reproductible, use `random.seed()` and avoid local paths.

## JSON

Each data set, task, and model should have corresponding json file. Names of JSON files should follow names in the `template` folder.

E.g. JSON for model should have name `model.json` not `c1994bdb7ecb3c6f3c8f3b35f4b47f1f.json`.

### dataset.json

Example: [dataset.json](dataset.json)

[Script for automatic generation of a JSON file for data from OpenML (Python).](/scripts/generate_dataset_json_siemashko.ipynb)

[Script for generation of a JSON file for from csv file (R).](/scripts/generate_dataset_json_hubertbaniecki.R)

Structure of dataset.json:
- id - id of the data set, naming convention is the same as for folder with data set (`source_name`),
- name - name of the data set in the source,
- added_by - GitHub username,
- date - addition date,
- source - source of the data set, e.g. `openml`, `kaggle`,
- url - url to the data set,
- number_of_features,
- number_of_instances,
- number_of_missing_values,
- number_of_instances_with_missing_values,
- variables - JSON object with summaries of variables, detailed structure below.
    
    Structure of variables:
    - name - variable name
    - type -  numerical or categorical
    - number_of_unique_values
    - number_of_missing_values
    - cat_frequencies - JSON object with frequencies of levels, null if variable is numerical
    - num_minimum - minimum, null if variable is categorical 
    - num_1qu - 1-st quartile, null if variable is categorical
    - num_median - median, null if variable is categorical
    - num_mean - mean, null if variable is categorical
    - num_3qu - 3-rd quartile, null if variable is categorical
    - num_maximum - maximum, null if variable is categorical

### task.json

Example: [task.json](task.json)

Structure of task.json
- id - id `task_target`, e.g.`regression_drinks`,
- added_by - GitHub username
- date - addition date
- dataset_id - id of data set
- type - regression or classification
- target - name of the target variable"

### model.json

Example: [model.json](model.json)

Structure of model.json
- id -  hash of model reated with `digest()` function from the `digest` R package, e.g. `5b2c4babcf5363847614d2b486a71534`,
    - mlr - hashed unnamed list. `list(task, learner)` where task is mlr Task and learner is corresponding mlr Learner. 
        - set Task parameter `id = "task"`.
    - caret - hashed unnamed list `list(formula, data, model, parameters)`, elements of list should be the same as in `train` function.
        - if model do not have parameters, fourth element of list should be NULL.
        - if train takes additional arguents, pass them in the end of list in alphabetical order, e.g. for `train(target ~ ., data ,"glm", tuneGrid, famliy = binomial)` hash is genereted from `list(target ~ ., data, "glm", tuneGrid, famliy = binomial)`.
        - 
-	added_by - GitHub username
-	date - addition date
- library - `"mlr"`, `"caret"`, or `"scikit"`
- model_name - name of model, specified in `Learner`, `train`, or name of scikit class. 
-	task_id - id of corresponding task
-	dataset_id - id of corresponding data set
-	parameters - JSON object with *all possible* parameters and their values. It should contain also values of parameter if default were used.

    For `mlr` learners you can use `getLearnerParVals()` and `getLearnerParamSet()` functions.  
- preprocessing - JSON object with description of variables after preprocessing, should have the same structure as variables in `dataset.json`


### audit.json

Example: [audit.json](audit.json)

Structure of audit.json
- id - id, `audit_hash`, e.g. `audit_5b2c4babcf5363847614d2b486a71534`,
- date - addition date
- added_by - GitHub username
- model_id 
- task_id
- dataset_id
- performance - JSON object with performance measures, e.g. 
      ```
      {
        "MSE":  10.94886
      }
      ```
      
## Session info

Each model should have corresponding session info saved in file `sessionInfo.txt` where hash is MD5 hash created for model with the `digest()` function from the `digest` R package.

```{r}
sink(paste0("sessionInfo.txt"))
sessionInfo()
sink()
```
