# Multi-Omics Dimension Reduction and Prediction

This project demonstrates data science techniques for analyzing **multi-omics data**.  
We focus on one type of dimension reduction (MFA) and two machine learning–style approaches (NMF, iClusterPlus).

The example dataset contains **121 colon cancer cases**:  
- 61 of type CMS1  
- 60 of type CMS3  
- Data covers:  
  - Expression of 500 genes  
  - Presence of damaging mutations in 200 genes  
  - Copy number variation (CNV) across 100 cytogenetic bands  

---

## Methods Overview

- **MFA (Multiple Factor Analysis):**  
  Fast, used 5 dimensions in this dataset. Best classification accuracy ≈ **0.934** using elastic net.

- **NMF (Nonnegative Matrix Factorization):**  
  Tested up to D = 10. Accuracy plateaued, ~10 errors, lower than MFA.

- **iClusterPlus:**  
  More time-consuming (~20s per run on tested data). Requires testing multiple seeds for each number of dimensions (D). Accuracy improves with D, reaching **0 errors at D = 20** for some seeds.

---

## Repository Structure

- `data_digest.R`  
  Reads the datasets and saves environment `objs.rds` containing:  
  - `X`: list of omics matrices  
  - `anno_col`: sample annotation dataframe  

- `data_heatmaps.R`  
  Produces heatmaps (`Heatmap_cnv.pdf`, `Heatmap_gex.pdf`, `Heatmap_mut.pdf`).  
  Clustering suggests **no single omic alone can identify subtypes**.

- `pred_mfa.R`  
  Runs MFA-based dimension reduction, saves heatmap (`mfa_Heatmap.pdf`) and elastic net classification results.  
  Run as:  
  ```bash
  Rscript pred_mfa.R > mfa_results

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

Output for our data:
```
 D  0  1  2  3  4  5  6  7  8  9 10 11 12 13
 2  .  .  .  .  .  .  .  .  .  .  1  6  6  2
 3  .  .  .  .  .  .  .  .  1  4  2  5  2  1
 ...
20  1  .  5  6  3  .  .  .  .  .  .  .  .  .
```
Interpretation:
	•	Rows = number of dimensions (D = 2…20)
	•	Columns = number of errors (0…13)
	•	Entries = number of random seeds with that error count (. means zero)

Observation: More dimensions → fewer errors; some runs at D = 20 achieved perfect classification.

⸻

## Future Work
- Add cross-validation script (pred_iCluster_CV.R).
- Richer outputs: for fixed D and seed count, tally misclassifications per sample to build a confidence model.

