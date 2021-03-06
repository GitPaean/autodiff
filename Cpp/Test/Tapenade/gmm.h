
#ifndef TEST_TAPENADE_GMM
#define TEST_TAPENADE_GMM

#include "../defs.h"
//#include "defs.h"

double arr_max(int n, double* x);

double logsumexp(int n, double* x);

double log_gamma_distrib(double a, double p);

double sqnorm(int d,
  double* x);

// p: dim
// k: number of components
// wishart parameters
// sum_qs: k sums of log diags of Qs
// Qdiags: d*k
// icf: (p*(p+1)/2)*k inverse covariance factors
double log_wishart_prior(int p, int k,
  Wishart wishart,
  double *sum_qs,
  double *Qdiags,
  double* icf);

void preprocess_qs(int d, int k,
  double* icf,
  double* sum_qs,
  double* Qdiags);

void Qtimesx(int d,
  double* Qdiag,
  double* ltri, // strictly lower triangular part
  double* x,
  double* out);

void subtract(int d,
  double* x,
  double* y,
  double* out);

// d: dim
// k: number of gaussians
// n: number of points
// alphas: k logs of mixture weights (unnormalized), so
//			weights = exp(log_alphas) / sum(exp(log_alphas))
// means: d*k component means
// icf: (d*(d+1)/2)*k inverse covariance factors 
//					every icf entry stores firstly log of diagonal and then 
//          columnwise other entris
//          To generate icf in MATLAB given covariance C :
//              L = inv(chol(C, 'lower'));
//              inv_cov_factor = [log(diag(L)); L(au_tril_indices(d, -1))]
// wishart: wishart distribution parameters
// x: d*n points
// err: 1 output
void gmm_objective(int d, int k, int n,
  double* alphas,
  double* means,
  double* icf,
  double *x,
  Wishart wishart,
  double *err);

// split of the outer loop over points
void gmm_objective_split_inner(int d, int k,
  double* alphas,
  double* means,
  double* icf,
  double *x,
  double *err);
// other terms which are outside the loop
void gmm_objective_split_other(int d, int k, int n,
  double* alphas,
  double* icf,
  Wishart wishart,
  double *err);

#endif // TEST_TAPENADE_GMM