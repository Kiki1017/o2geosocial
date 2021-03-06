#' Customise priors for outbreaker
#'
#' Priors can be specified in several ways in o2geosocial (see details and
#' examples). The most flexible way to specify a prior is to provide a prior
#' function directly. This function must take an argument 'param', which is a
#' list which contains all the states of the parameters and augmented data. See
#' the documentation of \link{create_param} for more information.
#'
#' @details
#' There are three ways a user can specify priors:\cr
#'
#' 1) Default: this is what happens when the 'config' has default values of
#' prior parameters.\cr

#' 2) Customized parameters: in this case, the prior functions are the default
#' ones from the package, but will use custom parameters, specified by the user
#' through \code{\link{create_config}}.\cr
#'
#' 3) Customized functions: in this case, prior functions themselves are
#' specified by the user, through the '...' argument of 'custom_priors'. The
#' requirements is that such functions must have either hard-coded parameters or
#' enclosed values. They will take a single argument which is a list containing
#' all model parameters with the class 'outbreaker_param'. ALL PRIORS functions
#' are expected to return values on a LOG SCALE.\cr
#'
#' Priors currently used for the model are:
#' \itemize{
#'
#' \item \code{pi} (reporting probability): default function is a beta
#' distribution implemented in \code{outbreaker:::cpp_prior_pi}. New prior
#' functions should use \code{x$pi} to refer to the current value of \code{pi},
#' assuming their argument is called \code{x}.
#'
#' \item \code{a} (first spatial parameter (population)): default function is 
#' a uniform distribution implemented in \code{outbreaker:::cpp_prior_a}. 
#' New prior functions should use \code{x$a} to refer to the current value of \code{a},
#' assuming their argument is called \code{x}.
#'
#' \item \code{b} (second spatial parameter (distance)): default function is 
#' a uniform distribution implemented in \code{outbreaker:::cpp_prior_b}.
#' New prior functions should use \code{x$b} to refer to the current value of \code{b},
#' assuming their argument is called \code{x}.
#'
#' }
#'
#' @author Initial version by Thibaut Jombart, rewritten by Alexis Robert (\email{alexis.robert@lshtm.ac.uk})
#'
#' @export
#'
#' @param ... A list or a series of named, comma-separated functions
#'     implementing priors. Each function must have a single argument, which
#'     corresponds to a 'outbreaker_param' list.
#'
#' @return A named list of custom functions with class \code{custom_priors}. Values
#'     set to \code{NULL} will be ignored and default functions will be used
#'     instead.
#'
#' @examples
#'
#' ## BASIC CONFIGURATION
#' custom_priors()
#'
#'
#' ## SPECIFYING PRIOR PARAMETERS
#' ## - this will need to be passed to outbreaker
#' default_config <- create_config()
#' new_config <- create_config(prior_a = c(0,5), prior_b = c(0,5),
#'                         prior_pi = c(2, 1))
#'
#' ## - to check the prior manually, default settings:
#' param <- list(mu = 0.001, pi = 0.9)
#' o2geosocial:::cpp_prior_pi(param, default_config)
#'
#' o2geosocial:::cpp_prior_pi(param, new_config)
#'
#' ## these correspond to:
#' dexp(0.001, 0.01, log = TRUE)
#' dbeta(0.9, 2, 1, log = TRUE)
#'
#'
#' ## SPECIFYING A PRIOR FUNCTION
#'
#' ## flat prior for pi between 0.5 and 1
#' f <- function(x) {ifelse(x$pi > 0.5, log(2), log(0))}
#' priors <- custom_priors(pi = f)
#' priors # this should be passed to outbreaker
#'
#' ## test the prior manually
#' priors$pi(list(pi=1))
#' priors$pi(list(pi=.6))
#' priors$pi(list(pi=.2))
#' priors$pi(list(pi=.49))
#'

custom_priors <- function(...) {
  
  ## This function returns a list of functions with the class
  ## 'outbreaker_priors'. It is used to process custom priors passed by the
  ## user. Each item of the list will be a prior function. If not provided,
  ## the default value is 'NULL', in which case c++ priors will have the
  ## default behaviour. This function tests some basic properties of the prior
  ## functions:
  
  ## 1) that if not NULL, the prior is a function
  
  ## 2) that if a function, it has a single argument called 'param'
  
  
  
  ## Get user-specified prior functions
  
  priors <- list(...)
  if (length(priors) == 1L && is.list(priors[[1]])) {
    priors <- priors[[1]]
  }
  
  
  ## Use user-provided priors where provided, default otherwise. The default
  ## for a prior is NULL, in which case the movement functions in C++ will use
  ## C++ versions.
  
  defaults <- list(pi = NULL, # reporting probability
                   a = NULL, #spatial param #1
                   b = NULL #spatial param #2
  )
  
  priors <- modify_defaults(defaults, priors, FALSE)
  priors_names <- names(priors)
  
  
  
  ## check all priors are functions
  
  function_or_null <- function(x) {
    is.null(x) || is.function(x)
  }
  
  is_ok <- vapply(priors, function_or_null, logical(1))
  
  if (!all(is_ok)) {
    culprits <- priors_names[!is_ok]
    msg <- paste0("The following priors are not functions: ",
                  paste(culprits, collapse = ", "))
    stop(msg)
  }
  
  
  ## check they all have a single argument
  
  with_one_arg <- function(x) {
    if(is.function(x)) {
      return (length(methods::formalArgs(x)) == 1L)
    }
    
    return(TRUE)
  }
  
  one_arg <- vapply(priors, with_one_arg, logical(1))
  
  if (!all(one_arg)) {
    culprits <- priors_names[!one_arg]
    msg <- paste0("The following priors don't have a single argument: ",
                  paste(culprits, collapse = ", "))
    stop(msg)
  }
  
  
  class(priors) <- c("custom_priors", "list")
  return(priors)
}







#' @rdname custom_priors
#'
#' @export
#'
#' @aliases print.custom_priors
#'
#' @param x an \code{outbreaker_config} object as returned by \code{create_config}.
#'

print.custom_priors <- function(x, ...) {
  cat("\n\n ///// outbreaker custom priors ///\n")
  cat("\nclass:", class(x))
  cat("\nnumber of items:", length(x), "\n\n")
  
  is_custom <- !vapply(x, is.null, FALSE)
  
  
  names_default <- names(x)[!is_custom]
  if (length(names_default) > 0) {
    cat("/// custom priors set to NULL (default used) //\n")
    print(x[!is_custom])
  }
  
  
  names_custom <- names(x)[is_custom]
  if (length(names_custom) > 0) {
    cat("/// custom priors //\n")
    print(x[is_custom])
  }
  
  return(invisible(NULL))
  
}

