# <environment: R_GlobalEnv>
# Seed: 5 Dimension: 2 
# 3 x 1 sparse Matrix of class "dgCMatrix"
#             lambda.min
# (Intercept) -2.4983127
# V1           1.4065620
# V2           0.2569497
#          Observed
# Predicted  0  1
#         0 52 12
#         1  8 49
# Seed: 7 Dimension: 2 
# 3 x 1 sparse Matrix of class "dgCMatrix"
#             lambda.min
# (Intercept) -2.4983130
# ...
BEGIN { minerr = 100 }
/^Seed/  {
  d = $4
  if (!mindim) mindim = d
}
/^Predicted/ {
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
