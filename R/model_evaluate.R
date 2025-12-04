#' Evaluate in-sample or out-of-sample logistic model performance
#'
#' This function evaluates the performance of a logistic regression model. 
#' Users can specify whether to perform in-sample evaluation on the training data 
#' or out-of-sample evaluation via cross-validation. The function returns key 
#' classification metrics: accuracy, precision, recall, and F1 score, allowing 
#' for a comprehensive assessment of model performance.
#'
#' @param df a data frame containing the predictors and response for the model
#' @param response A character string specifying the response variable with 2 variables.
#' @param baseline Optional. A character string specifying the reference
#'   level of the response variable. If supplied, the response factor will
#'   be re-leveled to this baseline.
#'
#' @details
#' This function assesses a logistic regression model's predictive performance. 
#' In-sample evaluation uses the training data to measure how well the model 
#' fits the data it was trained on. Out-of-sample evaluation uses 
#' cross-validation to estimate how well the model generalizes to unseen data.  
#' 
#' The function computes standard classification metrics:
#' 
#' - **Accuracy:** proportion of correct predictions  
#' - **Precision:** proportion of predicted positives that are actually positive  
#' - **Recall:** proportion of actual positives correctly predicted  
#' - **F1 score:** harmonic mean of precision and recall  
#' 
#'
#' @return
#'   \itemize{
#'     \item \code{accuracy}: proportion of correct predictions
#'     \item \code{precision}: proportion of predicted positives that are actually positive
#'     \item \code{recall}: proportion of actual positives correctly predicted
#'     \item \code{f1}: harmonic mean of precision and recall
#'   }
#' For cross-validation evaluation, these metrics are averaged across all folds.
#'
#' @examples
#' \dontrun{
#' df <- data.frame(
#'   y = c("no", "yes", "no", "yes"),
#'   x = c(1, 2, 3, 4)
#' )
#'
#'
#' model_evaluate(formula = y ~ x1 + x2, data = df, type = "baseline", folds = 5, cutoff = .5)
#' }
#'
#' @export


model_evaluate <- function(
    formula,
    data,
    type = c("insample", "cv"),
    folds = 5,
    cutoff = 0.5,
    baseline = NULL
) {
  type <- match.arg(type)
  
  compute_metrics <- function(y_true, y_prob, cutoff) {
    y_pred <- ifelse(y_prob >= cutoff, 1, 0)
    
    TP <- sum(y_true == 1 & y_pred == 1)
    TN <- sum(y_true == 0 & y_pred == 0)
    FP <- sum(y_true == 0 & y_pred == 1)
    FN <- sum(y_true == 1 & y_pred == 0)
    
    accuracy  <- (TP + TN) / (TP + TN + FP + FN)
    precision <- ifelse(TP + FP == 0, NA, TP / (TP + FP))
    recall    <- ifelse(TP + FN == 0, NA, TP / (TP + FN))
    f1        <- ifelse(is.na(precision) | is.na(recall) |
                          (precision + recall) == 0,
                        NA,
                        2 * precision * recall / (precision + recall))
    
    data.frame(
      accuracy = accuracy,
      precision = precision,
      recall = recall,
      f1 = f1
    )
  }
  
  # Helper to convert response to numeric 0/1
  prepare_response <- function(y, baseline = NULL) {
    if (is.factor(y) || is.character(y)) {
      y <- factor(y)
      if (!is.null(baseline)) {
        y <- relevel(y, ref = baseline)
      }
      y <- as.numeric(y) - 1
    }
    return(y)
  }
  
  # ---------------------------
  # IN-SAMPLE EVALUATION
  # ---------------------------
  if (type == "insample") {
    model <- fit_logistic(df = data, formula = formula)
    y_true <- prepare_response(model$y, baseline)
    y_prob <- fitted(model)
    return(compute_metrics(y_true, y_prob, cutoff))
  }
  
  # ---------------------------
  # CROSS-VALIDATION EVALUATION
  # ---------------------------
  if (type == "cv") {
    set.seed(123)
    fold_ids <- sample(rep(1:folds, length.out = nrow(data)))
    metrics_list <- vector("list", folds)
    
    for (k in 1:folds) {
      train_data <- data[fold_ids != k, ]
      test_data  <- data[fold_ids == k, ]
      
      model <- fit_logistic(df = train_data, formula = formula)
      y_prob <- predict(model, newdata = test_data, type = "response")
      
      y_true <- prepare_response(test_data[[all.vars(formula)[1]]], baseline)
      
      metrics_list[[k]] <- compute_metrics(y_true, y_prob, cutoff)
    }
    
    out <- do.call(rbind, metrics_list)
    avg <- as.data.frame(as.list(colMeans(out, na.rm = TRUE)))
    return(avg)
  }
}