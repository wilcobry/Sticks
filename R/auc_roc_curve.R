#' Create ROC curve and calculate AUC
#'
#' This function calculates the ROC curve for a logistic regression model and
#' computes the Area Under the Curve (AUC). The model is fitted internally using 
#' the \code{fit_logistic()} function. The response can be numeric (0/1), logical, 
#' factor, or character (e.g., "yes"/"no"), and it will automatically be converted 
#' to 0/1. The ROC curve is plotted, and the function returns the numeric AUC value.
#'
#' @param formula A logistic regression formula (e.g., \code{y ~ x1 + x2}).
#' @param data A data frame containing the response and predictors specified in the formula.
#' @param type Character. Either \code{"insample"} (default) to evaluate on the full dataset
#'   or \code{"cv"} to perform cross-validation.
#' @param folds Integer. Number of folds to use if \code{type = "cv"} (default 5).
#'
#' @details
#' The ROC curve and the corresponding Area Under the Curve (AUC) provide a visual
#' and quantitative assessment of a logistic model's classification performance. 
#' A higher AUC indicates better discrimination between positive and negative classes.
#' 
#' - \code{type = "insample"} evaluates the model on the full training data.  
#' - \code{type = "cv"} evaluates the model via cross-validation, combining out-of-sample
#'   predictions from all folds.
#'
#' @return
#' A numeric value of the AUC. The function also produces a plot of the ROC curve.
#'
#' @examples
#' \dontrun{
#' library(ISLR)
#' data(Default)
#'
#' # In-sample ROC and AUC
#' auc_roc_curve(default ~ balance + income + student,
#'                               data = Default, type = "insample")
#'
#' @export


auc_roc_curve <- function(formula, data, type = c("insample", "cv"), folds = 5) {
  type <- match.arg(type)
  
  compute_auc <- function(y_true, y_prob) {
    # Sort descending
    o <- order(y_prob, decreasing = TRUE)
    y_true <- y_true[o]
    y_prob <- y_prob[o]
    
    # Compute TPR/FPR
    P <- sum(y_true == 1)
    N <- sum(y_true == 0)
    tpr <- cumsum(y_true == 1) / P
    fpr <- cumsum(y_true == 0) / N
    tpr <- c(0, tpr)
    fpr <- c(0, fpr)
    
    # Plot ROC
    plot(fpr, tpr, type = "l",
         xlab = "False Positive Rate",
         ylab = "True Positive Rate",
         main = ifelse(type == "cv", "Cross-Validated ROC Curve", "ROC Curve"))
    abline(0, 1, lty = 2, col = "black")
    
    # Compute AUC
    auc <- sum(diff(fpr) * (head(tpr, -1) + tail(tpr, -1)) / 2)
    return(auc)
  }
  
  # ---------------------------
  # In-sample
  # ---------------------------
  if (type == "insample") {
    model <- fit_logistic(df = data, formula = formula)
    y_true <- model$y
    if (is.factor(y_true)) y_true <- as.numeric(y_true) - 1
    y_prob <- fitted(model)
    
    auc <- compute_auc(y_true, y_prob)
    return(auc)
  }
  
  # ---------------------------
  # Cross-validation
  # ---------------------------
  if (type == "cv") {
    set.seed(123)
    fold_ids <- sample(rep(1:folds, length.out = nrow(data)))
    
    y_true_all <- numeric(0)
    y_prob_all <- numeric(0)
    
    for (k in 1:folds) {
      train_data <- data[fold_ids != k, ]
      test_data  <- data[fold_ids == k, ]
      
      model <- fit_logistic(df = train_data, formula = formula)
      y_prob <- predict(model, newdata = test_data, type = "response")
      y_true <- test_data[[all.vars(formula)[1]]]
      
      # Convert to 0/1 if needed
      if (is.factor(y_true)) y_true <- as.numeric(y_true) - 1
      else if (is.character(y_true)) y_true <- as.numeric(factor(y_true)) - 1
      else if (is.logical(y_true)) y_true <- as.numeric(y_true)
      
      y_true_all <- c(y_true_all, y_true)
      y_prob_all <- c(y_prob_all, y_prob)
    }
    
    auc <- compute_auc(y_true_all, y_prob_all)
    return(auc)
  }
}