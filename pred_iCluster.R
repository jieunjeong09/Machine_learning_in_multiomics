#!/usr/bin/env Rscript --vanilla
list2env(readRDS("objs.rds"), envir = .GlobalEnv)
limits <- as.integer(commandArgs(trailingOnly = TRUE))
Ll <- length(limits
Dmin  <-  ifelse(Ll < 2, 2, limits[1])
Dmax  <-  ifelse(Ll < 2, 2, limits[2])
SeedN <-  ifelse(Ll < 3, 5, limits[3])
library(iClusterPlus)
library(glmnet)   # elastic net / logistic regression
# Multiple factor analysis
x1 <- X[[1]]
x2 <- X[[2]]
x3 <- X[[3]]
y <- as.integer(anno_col$cms == "CMS1")
row_names <- colnames(x1)

for (D in 2:15) {
  for (s in (1:15)*2) {
    set.seed(s)
    r.icluster <- iClusterPlus::iClusterPlus(
      t(x1),t(x2),t(x3),
      type = c("gaussian", "binomial", "multinomial"), # distributions of omics
      K = D, # Provide the number of factors to learn
      alpha = c(1, 1, 1), # as well as other model parameters
      lambda = c(.03, .03, .03)
    )
  # extract the H matrix
    H <- as.matrix(r.icluster$mean)
    rownames(H) <- row_names
    cvfit <- cv.glmnet(
      H, y,
      family = "binomial",
      alpha = 0,         # ridge regression (good for stability)
      nfolds = 5         # change to 10 or LOOCV if sample size small
    )
    cat("seed and dimension: ")
    cat (s)
    cat (" ")
    print(D)
    # best model
    coef(cvfit, s = "lambda.min")
    pred <- predict(cvfit, H, s = "lambda.min", type = "class")
  # confusion matrix
    print(table(Predicted = pred, Observed = y))
  }
}
