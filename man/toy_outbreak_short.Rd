% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/doc_data.R
\docType{data}
\name{toy_outbreak_short}
\alias{toy_outbreak_short}
\title{Simulated outbreaks}
\format{
An object of class \code{list} of length 3.
}
\usage{
toy_outbreak_short
}
\description{
Second dataset used to illustrate \code{o2geosocial}. (toy_outbreak_short) is a 
smaller data set (75 cases), spread across different Census tracks in Ohio 
(population and location of each region taken from 
https://www.census.gov/geographies/reference-files/2010/geo/2010-centers-population.html).
The list contains the following:
}
\details{
\itemize{

\item \code{$cases}: A data table summarising the epidemiological features of the
75 cases. It contains the ID, state, onset date,  genotype, Census tract, age group,
import status, cluster, generation and infector of the cases.

\item \code{$dt_regions}: A data table containing the ID, population, longitude 
and latitude of each region. Should be used to compute the distance matrix, using 
the package geosphere.

\item \code{$age_contact}: A matrix indicating the number of contacts between 
age groups

}
}
\examples{
data("toy_outbreak_short")
names(toy_outbreak_short)
toy_outbreak_short

}
\author{
Alexis Robert \email{alexis.robert@lshtm.ac.uk}
}
\keyword{datasets}
