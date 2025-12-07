
# Test #1 -----------------------------------------------------------------
library(ISLR)
df <- Default

mod1 <- fit_logistic(df = df, formula = default ~ ., baseline = "No")
summary(mod1)

monotonicity_plots(df, "default")

model_evaluate(formula = default ~ ., data = df, type = "cv", folds = 5, cutoff = .5)

auc_roc_curve(formula = default ~ ., data = df, type = "cv", folds = 5)



