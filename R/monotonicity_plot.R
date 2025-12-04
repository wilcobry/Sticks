#' Create monotonicity plots for numeric predictors in a logistic model
#'
#' This function fits monotonicity plots for all numeric predictors 
#' by automatically identifying the numeric predictors, 
#' setting a desired baseline level for the response, and converting the 
#' response factor to a 0/1 numeric variable.
#'
#' @param df a data frame containing the predictors and response for the model
#' @param response A character string specifying the response variable with 2 variables.
#' @param baseline Optional. A character string specifying the reference
#'   level of the response variable. If supplied, the response factor will
#'   be re-leveled to this baseline.
#'
#' @details
#' Analyzing model diagnostics becomes simpler using this function because it 
#' automates the process of creating monotonicity plots by identifying numeric 
#' variables and producing the monotonicity plots
#'
#'
#' @return
#'  \code{ggplot2} objects.
#'
#' @examples
#' \dontrun{
#' df <- data.frame(
#'   y = c("no", "yes", "no", "yes", "no", "yes", "no", "yes"),
#'   x = c(1, 2, 3, 4, 3, 7, 2, 6)
#' )
#'
#' monotonicity_plots(df, response = "y", baseline = "no")
#' }
#'
#' @export


monotonicity_plots <- function(df, response, baseline = NULL) {
  library(ggplot2)
  
  numeric_cols <- names(df)[sapply(df, is.numeric)]

  numeric_cols <- setdiff(numeric_cols, response)

  y_vec <- df[[response]]
  if (is.character(y_vec)) {
    y_vec <- factor(y_vec)
  }
  if (is.factor(y_vec)) {
    if (!is.null(baseline)) {
      y_vec <- relevel(y_vec, ref = baseline)
    }
    y_vec <- as.numeric(y_vec) - 1
  } else if (!is.numeric(y_vec)) {
    stop("Response must be numeric or factor")
  }

  # Loop through numeric columns and print plots
  for (var in numeric_cols) {
    p <- ggplot(df, aes_string(x = var, y = "y_vec")) +
      geom_jitter(height = 0.05, width = 0, alpha = 0.2) +
      geom_smooth(method = "gam", method.args = list(family = "binomial"), se = FALSE) +
      ggtitle(paste("Monotonicity of", var, "vs", response))

    print(p)
  }
}
