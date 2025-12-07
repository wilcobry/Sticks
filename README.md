# Sticks

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

`Sticks` is an R package designed to streamline logistic regression. 
The package provides functions to fit logistic regression models, assess model diagnostics,
and perform model evaluation in a clean and reproducible way. 

---

## Overview

`Sticks` is an R package designed to simplify the process of fitting, diagnosing, and evaluating logistic regression models. The package focuses on three main components:

1. **Model Fitting:**  
   Provides `fit_logistic()`, a wrapper around `glm()` that automatically handles baseline specification and factor conversion, making model fitting quick and reproducible.

2. **Diagnostic Tools:**  
   Includes functions like `monotonicity_plots()` to visually assess the relationships between numeric predictors and the outcome, helping verify assumptions of logistic regression.

3. **Model Evaluation:**  
   Offers functions such as `model_evaluate()` and `auc_roc_curve()` to compute evaluation metrics (accuracy, precision, recall, AUC) and generate ROC plots, either in-sample or via cross-validation.


---

## Installation

Install the development version from GitHub:

```r
install.packages("remotes")
remotes::install_github("wilcobry/Sticks")
```

## Implementation

### 1. `fit_logistic(df, formula, baseline)`
- **Purpose:** Fit a logistic regression model.  
- **Arguments:**  
  - `df`: Data frame with predictors and response.  
  - `formula`: Model formula, e.g., `y ~ x1 + x2`.  
  - `baseline`: Baseline level for the response variable.  
- **Key Features:**  
  - Automatically handles factorization of categorical variables.  
  - Converts the response to binary 0/1 if needed.  
  - Allows specification of a baseline level.  

### 2. `monotonicity_plots(df, response, baseline)`
- **Purpose:** Generate monotonicity plots for numeric predictors.  
- **Arguments:**  
  - `df`: Data frame with predictors and response.  
  - `response`: Response variable.  
  - `baseline`: Baseline level for the response.  
- **Key Features:**  
  - Automatically identifies numeric predictors.  
  - Simplifies diagnostic plotting for logistic regression assumptions.  

### 3. `model_evaluate(formula, data, type, folds, cutoff, baseline)`
- **Purpose:** Compute evaluation metrics for logistic regression models.  
- **Arguments:**  
  - `formula`: Model formula.  
  - `data`: Data frame with predictors and response.  
  - `type`: `"insample"` or `"cv"` for evaluation type.  
  - `folds`: Number of cross-validation folds.  
  - `cutoff`: Threshold for classifying predictions.  
  - `baseline`: Baseline level for the response.  
- **Key Features:**  
  - Performs cross-validation internally.  
  - Returns multiple evaluation metrics (accuracy, precision, recall) in one function.  

### 4. `auc_roc_curve(formula, data, type, folds)`
- **Purpose:** Generate ROC curve and compute AUC.  
- **Arguments:**  
  - `formula`: Model formula.  
  - `data`: Data frame with predictors and response.  
  - `type`: `"insample"` or `"cv"` for evaluation type.  
  - `folds`: Number of cross-validation folds.  
- **Key Features:**  
  - Provides quick in-sample or out-of-sample ROC curves and AUC values.  

### Example
```r
#example dataset
library(ISLR)
df <- Default

#fits a logistic regression model based on the provided dataset without factorizing variables beforehand
mod1 <- fit_logistic(df = df, formula = default ~ ., baseline = "No")

#uses glm() within fit_logisitc() creating the same model output as glm()
summary(mod1)

#creates monotonicity plots for all numeric predictors in the data
monotonicity_plots(df, "default")

#returns model evaluation metrics based on the specified type (insample or cv)
model_evaluate(formula = default ~ ., data = df, type = "cv", folds = 5, cutoff = .5)

#produces ROC plot and area under the curve
auc_roc_curve(formula = default ~ ., data = df, type = "cv", folds = 5)
```

## Comparison to Other R Packages

`Sticks` is designed to fill a niche in logistic regression workflows by combining convenience, 
diagnostics, and evaluation in a single package. Here's how it compares to other commonly used R packages:

- **`stats::glm`**  
  - Base R’s `glm()` is very flexible and allows for logistic regression modeling.  
  - However, `glm()` does not provide built-in functions for monotonicity checks, cross-validation metrics, or ROC/AUC visualization.  
  - `Sticks` wraps `glm()` functionality and adds these diagnostics and evaluation tools, reducing the need for separate code and packages.

- **`caret`**  
  - `caret` offers model training, cross-validation, and resampling for many model types.  
  - While powerful, `caret` requires multiple steps (preprocessing, trainControl, metric extraction) to achieve a similar workflow.  
  - `Sticks` provides a simpler, streamlined workflow for logistic regression specifically, with consistent default outputs and plotting functions designed for quick insights.

- **`rms` / `Hmisc`**  
  - Packages like `rms` provide advanced regression modeling, validation, and visualization tools, but the syntax can be complex, and the learning curve is higher.  
  - `Sticks` focuses on a straightforward approach to logistic regression diagnostics, making it easier for users who want meaningful plots and evaluation metrics without extensive setup.

**Design Trade-offs:**  
`Sticks` trades some generality for simplicity and reproducibility in logistic regression workflows. While it does not handle every type of model or advanced features (e.g., penalized regression, multi-class classification), it provides a concise, 
all-in-one toolset for quickly fitting, evaluating, and diagnosing logistic regression models.

