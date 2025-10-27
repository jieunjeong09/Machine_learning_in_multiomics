# Multi-Omics Dimension Reduction and Prediction

This project demonstrates data science techniques for analyzing **multi-omics data**.  
We focus on one type of dimension reduction (MFA) and two machine learning–style approaches (NMF, iClusterPlus).

The example dataset here originates from The Cancer Genome Atlas Pan-Cancer Project, described in *Nature Genetics* 45(10):1113-1120, 2013.  It contains **121 colon cancer cases**:  
- 61 of type CMS1  
- 60 of type CMS3  
- Data covers:  
  - Expression of 500 genes  
  - Presence of damaging mutations in 200 genes  
  - Copy number variation (CNV) across 100 cytogenetic bands  

---

## Methods Overview

Dimension reduction program reduce dimension to `D`, in the case of MFA, the method is deterministic and has a data dependent maximum dimension, for NMF and
iClusterPlus, tested dimensions are up to `D = 30` for MFA and up to `D = 20` for iClusterPlus.  After dimension reduction, I applied *ridge regression* implemented with `cv.glmnet` with parameter `alpha = 0`.  Selecting the best method may require extensive testing, here I tested different dimensions, and for probabilistic methods, with 15 seeds, and we can see clear gains from making many tests.  The objective here is to obtain high *accuracy a*, equivalently, small number or *errors e* where *a = 1 - e/121* (because we predict for 121 samples).

- **MFA (Multiple Factor Analysis):**  
  Fast, used 5 dimensions in this dataset. Best number of errors is 8 (accuracy 0.934).

- **NMF (Nonnegative Matrix Factorization):**  
  Tested up to `D = 30`. For `D = 29` the least number of errors was 4 (accuracy 0.967

- **iClusterPlus:**  
  More time-consuming (~20s per run on tested data, while NMF, ~7s per run).  For `D = 20`, the least number of errors was 0 (accuracy 1!!!). 
---

## Repository Structure

- `data_digest.R`  
  Reads the datasets and saves environment `objs.rds` containing:  
  - `X`: list of omics matrices  
  - `anno_col`: sample annotation dataframe  

- `data_heatmaps.R`  
  Produces heatmaps (`Heatmap_cnv.pdf`, `Heatmap_gex.pdf`, `Heatmap_mut.pdf`).  
  Clustering suggests **no single omic alone can identify subtypes**
  
- `pred_mfa.R`  
  Runs MFA-based dimension reduction, saves heatmap (`mfa_Heatmap.pdf`) and elastic net classification results.  
  Run as:  
  ```bash
  Rscript pred_mfa.R 2 20 15 > mfa.r1 &
  Rscript pred_mfa.R 21 30 15 >> mfa.r2 &
  [after jobs complete]
  cat mfa.r* | awk -f nmf_table.awk 
  ```  
- `pred_iCluster.R`

Runs iClusterPlus for a specified dimension range and 15 seeds.
Usage example on Mac Mini:

```bash
time Rscript pred_iCluster.R 2 8 > iCluster.r1 &
time Rscript pred_iCluster.R 9 14 > iCluster.r2 &
time Rscript pred_iCluster.R 15 20 > iCluster.r3 &
[after jobs complete]
cat iCluster.r* | awk -f iCluster_table.awk
```
## Results

`awk` scripts summarize results in the terminal windows as a table with a row for every dimension tested and
a column for each number of errors resulting from a test (seed value).  The value is the number of seeds that
resulted in that number of errors, or a dot if none.

This is the table for NFA, showing only the rows achieving lower number of errors than the previous ones

```
 D  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 21 22
 2  .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  . 15  .  .
 4  .  .  .  .  .  .  .  .  .  .  .  .  .  .  1  . 14  .  .
 7  .  .  .  .  .  .  .  .  .  .  .  .  . 12  1  2  .  .  .
 8  .  .  .  .  .  .  .  .  .  .  .  1  1  6  .  .  6  1  .
10  .  .  .  .  .  .  .  .  .  2  1  1  2  4  3  .  1  .  1
12  .  .  .  .  .  .  .  .  1  2  5  4  2  .  1  .  .  .  .
20  .  .  .  .  .  .  .  1  3  5  .  2  3  1  .  .  .  .  .
22  .  .  .  .  .  1  1  1  3  1  1  2  2  2  .  1  .  .  .
24  .  .  .  .  1  .  2  1  5  .  4  .  1  1  .  .  .  .  .
28  .  .  .  2  1  .  1  1  .  1  5  1  2  1  .  .  .  .  .
29  1  .  1  1  .  2  1  4  3  .  1  1  .  .  .  .  .  .  .
```

And this is the table for `iClusterPlus`:
```
 D  0  1  2  3  4  5  6  7  8  9 10 11 12 13
 2  .  .  .  .  .  .  .  .  .  .  1  6  6  2
 3  .  .  .  .  .  .  .  .  1  4  2  5  2  1
 4  .  .  .  .  .  .  .  1  .  4  4  3  3  .
 5  .  .  .  .  .  .  1  1  3  4  5  .  1  .
 7  .  .  .  .  .  1  1  2  6  3  2  .  .  .
 8  .  .  .  .  2  4  3  3  2  .  1  .  .  .
 9  .  .  .  1  3  7  3  .  1  .  .  .  .  .
11  .  .  1  2  2  7  2  1  .  .  .  .  .  .
20  1  .  5  6  3  .  .  .  .  .  .  .  .  .
```


## Future Work
- Add cross-validation script (pred_iCluster_CV.R).
- Richer outputs: for fixed D and seed count, tally misclassifications per sample to build a confidence model.
- Explore biological interpretations, impact of the features

