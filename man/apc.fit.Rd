\name{apc.fit}
\alias{apc.fit}
\title{
  Fit an Age-Period-Cohort model to tabular data.
  }
\description{
  Fits the classical five models to tabulated rate data (cases,
  person-years) classified by two of age, period, cohort:
  Age, Age-drift, Age-Period, Age-Cohort and Age-Period-Cohort. There are no
  assumptions about the age, period or cohort classes being of the same
  length, or that tabulation should be only by two of the variables.
  Only requires that mean age and period for each tabulation unit is given.
  }
\usage{
apc.fit( data,
            A,
            P,
            D,
            Y,
        ref.c,
        ref.p,
          dist = c("poisson","binomial"),
         model = c("ns","bs","ls","factor"),
       dr.extr = "weighted",
          parm = c("ACP","APC","AdCP","AdPC","Ad-P-C","Ad-C-P","AC-P","AP-C"),
          npar = c( A=5, P=5, C=5 ),
         scale = 1,
         alpha = 0.05,
     print.AOV = TRUE )
  }
\arguments{
  \item{data}{Data frame with (at least) variables, \code{A} (age),
    \code{P} (period), \code{D} (cases, deaths) and \code{Y}
    (person-years). Cohort (date of birth) is computed as \code{P-A}.
    If this argument is given the arguments \code{A}, \code{P},
    \code{D} and \code{Y} are ignored.}
  \item{A}{Age; numerical vector with mean age at diagnosis for each unit.}
  \item{P}{Period; numerical vector with mean date of diagnosis for each
            unit.}
  \item{D}{Cases, deaths; numerical vector.}
  \item{Y}{Person-years; numerical vector. Also used as denominator for binomial
           data, see the \code{dist} argument.}
  \item{ref.c}{Reference cohort, numerical. Defaults to median date of
    birth among cases. If used with \code{parm="AdCP"} or \code{parm="AdPC"},
    the residual cohort effects will be 1 at \code{ref.c}}
  \item{ref.p}{Reference period, numerical. Defaults to median date of
    diagnosis among cases.}
  \item{dist}{Distribution (or more precisely: Likelihood) used for modeling.
              if a binomial model us used, \code{Y} is assumed to be the
              denominator; \code{"binomial"} gives a binomial model with logit
              link.}
  \item{model}{Type of model fitted:
    \itemize{
	    \item \code{ns} fits a model with natural splines for each of
	      the terms, with \code{npar} parameters for the terms.
      \item \code{bs} fits a model with B-splines for each of
	      the terms, with \code{npar} parameters for the terms.
	    \item \code{ls} fits a model with linear splines.
      \item \code{factor} fits a factor model with one parameter
	      per value of \code{A}, \code{P} and \code{C}. \code{npar}
	      is ignored in this case.
           }
      }
  \item{dr.extr}{Character or numeric.	
    How the drift parameter should be extracted from the
    age-period-cohort model. Specifies the inner product used for
    definition of orthogonality of the period / cohort effects to the
    linear effects --- in terms of a diagonal matrix.

    \code{"weighted"} (or "t") (default) uses the no. cases, \code{D},
    corresponding to the observed information about the log-rate
    (usually termed "theta", hence the "\code{t}"). \code{"r"} or \code{"l"} uses
    \code{Y*Y/D} corresponding to the observed information about the
    rate (usually termed "lambda", hence the "\code{l}"). \code{"y"}
    uses the person-years as the weight in the inner product. If given
    "\code{n}" (Naive) (well, in fact any other character value) will
    induce the use of the standard inner product putting equal weight on
    all units in the dataset.

    If given as a numeric vector this is used as the diagonal of the
    matrix inducing the inner product.

    The setting of this parameter has no effect on the fit of the model,
    only on the parametrization.
  }
  \item{parm}{Character. Indicates the parametrization of the effects.
    The first four refer to the ML-fit of the Age-Period-Cohort model,
    the last four give Age-effects from a smaller model and residuals
    relative to this. If one of the latter is chosen, the argument
    \code{dr.extr} is ignored. Possible values for \code{parm} are:
    \itemize{
      \item \code{"ACP"}: ML-estimates. Age-effects as rates for the
      reference cohort. Cohort effects as RR relative to the reference
      cohort. Period effects constrained to be 0 on average with 0 slope.
      \item \code{"APC"}: ML-estimates. Age-effects as rates for the
      reference period. Period effects as RR relative to the reference
      period. Cohort effects constrained to be 0 on average with 0 slope.
      \item \code{"AdCP"}: ML-estimates. Age-effects as rates for the
      reference cohort. Cohort and period effects constrained to be 0 on
      average with 0 slope. In this case returned effects do not
      multiply to the fitted rates, the drift is missing and needs to be
      included to produce the fitted values.
      \item \code{"AdPC"}: ML-estimates. Age-effects as rates for the
      reference period. Cohort and period effects constrained to be 0 on
      average with 0 slope. In this case returned effects do not
      multiply to the fitted rates, the drift is missing and needs to be
      included to produce the fitted values.
      \item \code{"Ad-C-P"}: Age effects are rates for the reference
      cohort in the Age-drift model (cohort drift). Cohort effects are from the model
      with cohort alone, using log(fitted values) from the Age-drift
      model as offset. Period effects are from the model with period
      alone using log(fitted values) from the cohort model as offset.
      \item \code{"Ad-P-C"}: Age effects are rates for the reference
      period in the Age-drift model (period drift). Period effects are from the model
      with period alone, using log(fitted values) from the Age-drift
      model as offset. Cohort effects are from the model with cohort
      alone using log(fitted values) from the period model as offset.
      \item \code{"AC-P"}: Age effects are rates for the reference
      cohort in the Age-Cohort model, cohort effects are RR relative to
      the reference cohort. Period effects are from the model
      with period alone, using log(fitted values) from the Age-Cohort
      model as offset.
      \item \code{"AP-C"}: Age effects are rates for the reference
      period in the Age-Period model, period effects are RR relative to
      the reference period. Cohort effects are from the model
      with cohort alone, using log(fitted values) from the Age-Period
      model as offset.
    } }
  \item{npar}{The number of parameters/knots to use for each of the terms in
    the model. If it is vector of length 3, the numbers are taken as the
    no. of knots for Age, Period and Cohort, respectively. Unless it has
    a names attribute with vales "A", "P" and "C" in which case these
    will be used. The knots chosen are the quantiles
    \code{(1:nk-0.5)/nk} of the events (i.e. of \code{rep(A,D)})

    \code{npar} may also be a named list of three numerical vectors with
    names "A", "P" and "C", in which case these taken as the knots for
    the age, period and cohort effect, the smallest and largest element in
    each vector are used as the boundary knots.}
  \item{alpha}{The significance level. Estimates are given with
    (1-\code{alpha}) confidence limits.}
  \item{scale}{numeric(1), factor multiplied to the rate estimates before output.}
  \item{print.AOV}{Should the analysis of deviance table for the models
    be printed?}
  }
\value{
  An object of class "apc" (recognized by \code{\link{apc.plot}} and
  \code{\link{apc.lines}}) --- a list with components:
  \item{Type}{Text describing the model and parametrization returned}
  \item{Model}{The model object(s) on which the parametrization is based.}
  \item{Age}{Matrix with 4 columns: \code{A.pt} with the ages (equals
    \code{unique(A)}) and three columns giving the estimated rates with
    c.i.s.}
  \item{Per}{Matrix with 4 columns: \code{P.pt} with the dates of
    diagnosis (equals \code{unique(P)}) and three columns giving the
    estimated RRs with c.i.s.}
  \item{Coh}{Matrix with 4 columns: \code{C.pt} with the dates of birth
    (equals \code{unique(P-A)}) and three columns giving the estimated
    RRs with c.i.s.}
  \item{Drift}{A 3 column matrix with drift-estimates and c.i.s: The
    first row is the ML-estimate of the drift (as defined by
    \code{drift}), the second row is the estimate from the Age-drift
    model. The first row name indicates which type of inner product were
    used for projections. For the sequential parametrizations, only the
    latter is given.}
  \item{Ref}{Numerical vector of length 2 with reference period and cohort.
             If ref.p or ref.c was not supplied the corresponding element is NA.}
  \item{AOV}{Analysis of deviance table comparing the five classical
    models.}
  \item{Type}{Character string explaining the model and the parametrization.}
  \item{Knots}{If \code{model} is one of \code{"ns"} or \code{"bs"}, a list
    with three components: \code{Age}, \code{Per}, \code{Coh}, each one a
    vector of knots. The max and the min are the boundary knots.}
}
\details{
   Each record in the input data frame represents a subset of a Lexis
   diagram. The subsets need not be of equal length on the age and
   period axes, in fact there are no restrictions on the shape of
   these; they could be Lexis triangels for example. The requirement is
   that \code{A} and \code{P} are coded with the mean age and calendar
   time of observation in the subset. This is essential since \code{A}
   and \code{P} are used as quantitative variables in the models.

   This is a different approach relative to the vast majority of the
   uses of APC-models in the literature where a factor model is used for
   age, perido and cohort effects. The latter can be obtained by using
   \code{model="factor"}.
   }
\references{
   The considerations behind the parametrizations used in this function
   are given in details in:
   B. Carstensen: Age-Period-Cohort models for the Lexis diagram.
   Statistics in Medicine, 10; 26(15):3018-45, 2007.

   Various links to course material etc. is available through \url{http://BendixCarstensen.com/APC}
   }
\author{
   Bendix Carstensen, \url{http://BendixCarstensen.com}
   }
\seealso{
   \code{\link{LCa.fit}},
   \code{\link{apc.frame}},
   \code{\link{apc.lines}},
   \code{\link{apc.plot}}.
   }
\examples{
library( Epi )
data(lungDK)

# Taylor a dataframe that meets the requirements
exd <- lungDK[,c("Ax","Px","D","Y")]
names(exd)[1:2] <- c("A","P")

# Two different ways of parametrizing the APC-model, ML
ex.H <- apc.fit( exd, npar=7, model="ns", dr.extr="Holford",  parm="ACP", scale=10^5 )
ex.W <- apc.fit( exd, npar=7, model="ns", dr.extr="weighted", parm="ACP", scale=10^5 )

# Sequential fit, first AC, then P given AC.
ex.S <- apc.fit( exd, npar=7, model="ns", parm="AC-P", scale=10^5 )

# Show the estimated drifts
ex.H[["Drift"]]
ex.W[["Drift"]]
ex.S[["Drift"]]

# Plot the effects
fp <- apc.plot( ex.H )
apc.lines( ex.W, frame.par=fp, col="red" )
apc.lines( ex.S, frame.par=fp, col="blue" )
}
\keyword{models}
\keyword{regression}