#!/usr/bin/env Rscript --vanilla
list2env(readRDS("objs.rds"), envir = .GlobalEnv)
Heatmap <- function(x, y, b = NA) {
  if (is.na(b)) {
    pheatmap::pheatmap(
      x,
      annotation_col = anno_col,
      show_colnames = FALSE,
      show_rownames = FALSE,
      main = y
    )
  } else {
    pheatmap::pheatmap(
      x,
      annotation_col = anno_col,
      breaks = (-1:b) + 0.5,
      legend_breaks = 0:(b-1),
      color = viridisLite::viridis(b),  # Or use RColorBrewer::brewer.pal()
      show_colnames = FALSE,
      show_rownames = FALSE,
      main = y
    )
  }
}
hm_1 <- Heatmap(X[[1]],"Gene expression data")
hm_2 <- Heatmap(X[[2]],"Gene mutation data",2)
hm_3 <- Heatmap(X[[3]],"Cytoband copy numbers",3)
pdf("Heatmap_gex.pdf", width = 6, height = 6)
hm_1
dev.off
pdf("Heatmap_mut.pdf", width = 6, height = 6)
hm_2
dev.off
pdf("Heatmap_cnv.pdf", width = 6, height = 6)
hm_3
dev.off
# simpler definition
# Heatmap <- function(x,y) pheatmap::pheatmap(x, annotation_col = anno_col,
# show_colnames = FALSE, show_rownames = FALSE, main=y)
