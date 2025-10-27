#!/usr/bin/env Rscript --vanilla
list2env(readRDS("objs.rds"), envir = .GlobalEnv)
library(NMF)
library(glmnet)

# Parse arguments
limits <- as.integer(commandArgs(trailingOnly = TRUE))
Ll <- length(limits)
Dmin  <- ifelse(Ll < 2, 2, limits[1])
Dmax  <- ifelse(Ll < 2, 5, limits[2])
SeedN <- ifelse(Ll < 3, 5, limits[3])

# input of nmf must be nonnegative — handle negatives before normalization
# Normalize each omic block separately
for (i in 1:3) {
  x <- X[[i]]
  x <- x / rowSums(x)
  X[[i]] <- x / norm(x, type = "F")
}
# Combine normalized blocks
X_all <- do.call(rbind, X)
# Response variable
y <- as.integer(anno_col$cms == "CMS1")

# Row/column names
row_names <- colnames(X_all)  # useful for checking results on sample level

# Loop over factorization dimensions and seeds
for (D in Dmin:Dmax) {
  for (s in 2*(1:SeedN) + 3) {
    set.seed(s)  # to ensure reproducibility
    fit <- nmf(X_all, D, method = "Frobenius", seed = s)
    X_lat <- coef(fit) 

    # Logistic regression (ridge, alpha=0)
    cvfit <- cv.glmnet(t(X_lat), y, family = "binomial", alpha = 0, nfolds = 10)

    cat("Seed:", s, "Dimension:", D, "\n")

    # Extract and display coefficients
    print(coef(cvfit, s = "lambda.min"))

    # Predict on same latent space (for demonstration)
    pred <- predict(cvfit, t(X_lat), s = "lambda.min", type = "class")

    # Confusion matrix
    print(table(Predicted = pred, Observed = y))
  }
}

