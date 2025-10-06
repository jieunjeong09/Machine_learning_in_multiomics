#!/usr/bin/env Rscript --vanilla
list2env(readRDS("objs.rds"), envir = .GlobalEnv)
require(FactoMineR)
library(glmnet)   # elastic net / logistic regression

# Multiple factor analysis
X_all <- do.call(rbind, X) # binding the omics types together 
sizes <- sapply(X, nrow) # specifying the dimensions of each
cat("sizes "); print(sizes)

r.mfa <- FactoMineR::MFA(t(X_all),sizes,graph = FALSE)

# extract the H and W matrices from the MFA run result
H <- r.mfa$global.pca$ind$coord
W <- r.mfa$quanti.var$coord
cat("dim(H) dim(W): "); print(c(dim(H),dim(W)))
# visualize dimensions 1 and 2 of H
library(ggplot2)
DF <- as.data.frame(H)
DF$subtype <- anno_col$cms
p2 <- ggplot(DF, aes(x=Dim.1, y=Dim.2, color=subtype)) +
geom_point() + ggtitle("Scatter plot of MFA") +
geom_abline(intercept = 0.7,slope = 15, color = "orange")

# visualize all dimensions of H
pdf("mfa_Heatmap.pdf", width = 6, height = 4)
pheatmap::pheatmap(t(H), annotation_col = anno_col,
		show_colnames = FALSE,
		main = "MFA for multi-omics integration")
dev.off

# elastic net / logistic regression
Dmax <- dim(H)[2]
# response variable (factor with 2 levels)
y <- as.integer(anno_col$cms == "CMS1")
# glmnet expects numeric matrix + numeric response

# fit logistic regression with cross-validated regularization
for (D in 2:Dmax) {
  Hd <- H[,1:D]
  cvfit <- cv.glmnet(
    Hd, y,
    family = "binomial",
    alpha = 0,         # ridge regression (good for stability)
    nfolds = 5         # change to 10 or LOOCV if sample size small
  )
  print(coef(cvfit, s = "lambda.min")) # best model for D variable
  pred <- predict(cvfit, Hd, s = "lambda.min", type = "class")
  cat(table(Predicted = pred, Observed = y)) # confusion matrix
  cat(" ")
  print(mean(pred == y))   # training accuracy
}
