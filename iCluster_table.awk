# Loading required package: Matrix
# Loaded glmnet 4.1-10<environment: R_GlobalEnv>
# [1] 121   2
# seed and dimension: 2 [1] 2
#         Observed
# Predicted  0  1
#         0 56  7
#         1  4 54
BEGIN { minerr = 100 }
/^seed/  {
  d = $6
  if (!mindim) mindim = d
  getline # Observed
  getline # Predicted
  getline
  err = $3
  getline
  err += $2
  if (err < minerr) minerr = err
  if (err > maxerr) maxerr = err
  C[d, err]++
}
END {
  printf " D"
  for (i = minerr;  i <= maxerr;  i++)
    printf " %2d", i
  printf "\n"
  for (D = mindim;  D <= d;  D++) {
    printf "%2d", D
    for (e = minerr;  e <= maxerr;  e++) {
      c = C[D, e]+0
      if (c == 0)
        printf "  ."
      else
        printf " %2d", c
    }
    printf "\n"
  }
}
