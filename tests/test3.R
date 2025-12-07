
# Test 3 ------------------------------------------------------------------

df_titanic <- as.data.frame(Titanic)
df_titanic$Survived <- factor(df_titanic$Survived, levels = c("No", "Yes"))

mod_titanic <- fit_logistic(df_titanic, formula = Survived ~ Sex + Age + Class, baseline = "No")
summary(mod_titanic)

monotonicity_plots(df_titanic, "Survived")

model_evaluate(formula = Survived ~ Sex + Age + Class, data = df_titanic, type = "cv", folds = 5)

auc_roc_curve(formula = Survived ~ Sex + Age + Class, data = df_titanic, type = "cv", folds = 5)

