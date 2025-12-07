
# Test #2 -----------------------------------------------------------------
library(MLDataR)
library(tidyverse)

df2 <- heartdisease |> 
  mutate(FastingBS = ifelse(FastingBS == 1, "yes", "no"))

mod2 <- fit_logistic(df = df2, formula = HeartDisease ~ ., baseline = 0)
summary(mod2)

monotonicity_plots(df2, "HeartDisease")

model_evaluate(formula = HeartDisease ~ ., data = df2, type = "insample", folds = 5, cutoff = .5)

model_evaluate(formula = HeartDisease ~ ., data = df2, type = "cv", folds = 10, cutoff = .5)

auc_roc_curve(formula = HeartDisease ~ ., data = df2, type = "cv", folds = 5)