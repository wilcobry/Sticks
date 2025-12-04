#' Fit a Logistic Regression Model with Automatic Factor Handling
#'
#' This function fits a logistic regression model while automatically
#' converting character variables to factors, setting a desired baseline
#' level for the response, and converts the response factor
#' to a 0/1 numeric variable for modeling.
#'
#' @param df a data frame containing the predictors and response for the model
#' @param formula A logistic regression formula (e.g., \code{y ~ x1 + x2}).
#' @param baseline Optional. A character string specifying the reference
#'   level of the response variable. If supplied, the response factor will
#'   be re-leveled to this baseline.
#'
#' @details
#' This function makes logistic regression simpler than other logistic functions
#' by factorizing characters and ensuring the response is binary coded as 0/1
#' , where 0 corresponds to the
#' specified \code{baseline} (or the first factor level if no baseline is given).
#'
#'
#' @return
#' A fitted \code{glm} object with \code{family = binomial}.
#'
#' @examples
#' \dontrun{
#' df <- data.frame(
#'   y = c("no", "yes", "no", "yes"),
#'   x = c(1, 2, 3, 4)
#' )
#'
#' fit_logistic(df, y ~ x, baseline = "no")
#' }
#'
#' @export



fit_logistic <- function(df, formula, baseline = NULL) {

  df[] <- lapply(df, function(x) if(is.character(x)) factor(x) else x)

  
  response <- all.vars(formula)[1]
  if(!is.null(baseline) && is.factor(df[[response]])) {
    df[[response]] <- relevel(df[[response]], ref = baseline)
  }

  
  if(is.factor(df[[response]])) {
    df[[response]] <- as.numeric(df[[response]]) - 1
  }

  glm(formula, data = df, family = binomial)
}

