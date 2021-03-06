\name{ci.cum}
\alias{ci.cum}
\title{ Compute cumulative sum of estimates. }
\description{
Computes the cumulative sum of parameter functions and the
standard error of it. Optionally the exponential is applied to the
parameter functions before it is cumulated.
}
\usage{
ci.cum( obj,
    ctr.mat = NULL,
     subset = NULL,
       intl = 1,
      alpha = 0.05,
        Exp = TRUE,
     ci.Exp = FALSE,
     sample = FALSE )
}
\arguments{
  \item{obj}{A model object (of class
             \code{lm}, \code{glm},
             \code{coxph}, \code{survreg},
             \code{lme},\code{mer},\code{nls},\code{gnlm},
             \code{MIresult}
          or \code{polr}). }
  \item{ctr.mat}{ Contrast matrix defining the parameter functions from
    the parameters of the model. }
  \item{subset}{ Subset of the parameters of the model to which
    \code{ctr.mat} should be applied. }
  \item{intl}{ Interval length for the cumulation. Either a constant or
    a numerical vector of length \code{nrow(ctr.mat)}. }
  \item{alpha}{ Significance level used when computing confidence limits. }
  \item{Exp}{ Should the parameter function be exponentiated before it is
    cumulated?}
  \item{ci.Exp}{ Should the confidence limits for the cumulative rate be
  computed on the log-scale, thus ensuring that exp(-cum.rate) is always
  in [0,1]?}
  \item{sample}{Should a sample of the original parameters be used to
    compute a cumulative rate?}
}
\details{  
  The purpose of this function is to the compute cumulative rate
  (integrated intensity) at a set of points based on a model for the
  rates. 
  \code{ctr.mat} is a matrix which, when premultiplied to the parameters
  of the model reurn the (log)rates at a set of increasing time points. If log-rates are
  returned from the model, the they should be exponentiated before
  cumulated, and the variances computed accordingly. Since the primary
  use is for log-linear Poisson models the \code{Exp} parameter defaults
  to TRUE.

  The \code{ci.Exp} argument ensures that the confidence intervals for
  the cumulaive rates are alwys positive, so that exp(-cum.rate) is
  always in [0,1].
}
\value{
   A matrix with 4 columns: Estimate, lower and upper c.i. and standard
   error. If \code{sample} is TRUE, a sampled vector is reurned, if
   \code{sample} is numeric a matrix with \code{sample} columns is
   returned, each column a cumulative rate based on a random sample from
   the distribution of the parameter estimates.
}
\author{
  Bendix Carstensen,
  \url{http://BendixCarstensen.com}
}
\seealso{ See also \code{\link{ci.lin}} }
\examples{
# Packages required for this example
library( splines )
library( survival )
data( lung )
par( mfrow=c(1,2) )

# Plot the Kaplan-meier-estimator
plot( survfit( Surv( time, status==2 ) ~ 1, data=lung ) )

# Declare data as Lexis
lungL <- Lexis( exit=list("tfd"=time),
                exit.status=(status==2)*1, data=lung )
summary( lungL )

# Cut the follow-up every 10 days
sL <- splitLexis( lungL, "tfd", breaks=seq(0,1100,10) )
str( sL )
summary( sL )

# Fit a Poisson model with a natural spline for the effect of time.
# Extract the variables needed
D <- status(sL, "exit")
Y <- dur(sL)
tB <- timeBand( sL, "tfd", "left" )
MM <- ns( tB, knots=c(50,100,200,400,700), intercept=TRUE )
mp <- glm( D ~ MM - 1 + offset(log(Y)),
           family=poisson, eps=10^-8, maxit=25 )

# mp is now a model for the rates along the time scale tB

# Contrast matrix to extract effects, i.e. matrix to multiply with the
# coefficients to produce the log-rates: unique rows of MM, in time order.
T.pt <- sort( unique( tB ) )
T.wh <- match( T.pt, tB )

# ctr.mat=MM[T.wh,] selects the rates as evaluated at times T.pt:
Lambda <- ci.cum( mp, ctr.mat=MM[T.wh,], intl=diff(c(0,T.pt)) )

# Put the estimated survival function on top of the KM-estimator
matlines( c(0,T.pt[-1]), exp(-Lambda[,1:3]), lwd=c(3,1,1), lty=1, col="Red" )

# Extract and plot the fitted intensity function
lambda <- ci.lin( mp, ctr.mat=MM[T.wh,], Exp=TRUE )
matplot( T.pt, lambda[,5:7]*10^3, type="l", lwd=c(3,1,1), col="black", lty=1,
         log="y", ylim=c(0.2,20) )
}
\keyword{models}
\keyword{regression}
