#ifndef MEASLESOUTBREAKER_PRIORS_H
#define MEASLESOUTBREAKER_PRIORS_H



double cpp_prior_pi(Rcpp::List param, Rcpp::List config,
                    Rcpp::RObject custom_function);

double cpp_prior_a(Rcpp::List param, Rcpp::List config,
                   Rcpp::RObject custom_function);

double cpp_prior_b(Rcpp::List param, Rcpp::List config,
                   Rcpp::RObject custom_function);

double cpp_prior_all(Rcpp::List param, Rcpp::List config,
                     Rcpp::RObject custom_functions = R_NilValue);


#endif

