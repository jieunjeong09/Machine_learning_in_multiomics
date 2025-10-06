#!/usr/bin/env Rscript --vanilla
# input prefix
paD <- "/Users/jieun/Work/Multiomics/Datasets/COREAD_CMS13_"
DataTable <- function(x) read.csv(paste0(paD,x,".csv"), row.names=1,
                           check.names = FALSE)
DataMatrix <- function(x) as.matrix(DataTable(x))
# column: patient, row: gene or cytoband
x1 <- DataMatrix("gex")  # gene expression
x2 <- DataMatrix("muts") # mutation data
x3 <- DataMatrix("cnv")  # copy number variation
s <- DataTable("subtypes")

# consistency check, are patients the same and in the same order
patients <- colnames(x1)
stopifnot(identical(colnames(x2),patients))
stopifnot(identical(colnames(x3),patients))
stopifnot(identical(row.names(s),patients))

# in x2, mutation data, it appears that every row has
# exactly two distinct values,
# smaller one is 0, larger one is a positive numeric, but it is safer to check
for (i in 1:dim(x2)[1]) {
  a <- sort(unique(x2[i,]))
  stopifnot(length(a) == 2)
  stopifnot(a[1] == 0)
  stopifnot(a[2] > 0)
}
x2 <- (x2 > 0)+0  # we replace positive values with 1
# in x3, copy number data, it appears that every row has
# two or three values, the smallest one is 0, the other in (0.1, 0.4)
# if there are three values, the middle is in (0.1,0.2) and 
# the larger is exactly twice larger
# if there are two values, the large one in in (0.11,0.2) or in (0.22,0.4)
# but it is safer to check
for (i in 1:dim(x3)[1]) {
  a <- sort(unique(x3[i,]))
  L <- length(a)
  stopifnot(L == 2 || L == 3)
  stopifnot(a[1] == 0 && a[2] > 0.11 &&  a[2] != 0.2 && a[2] < 0.4)
  stopifnot(L == 2 || abs(2*a[2]-a[3]) < 1.0e-10)
  stopifnot(L == 3 || a[2] < 0.2 || a[2] > 0.22)
}
x3 <- (x3 > 0.1) + (x3 > 0.2) # normalize values to integers 0, 1, 2

y <- DataTable("subtypes")
anno_col <- data.frame(cms=as.factor(y$cms_label), row.names = rownames(y))
saveRDS(list(X = list(x1,x2,x3), anno_col = anno_col), "objs.rds")
