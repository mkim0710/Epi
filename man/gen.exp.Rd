\name{gen.exp}
\alias{gen.exp}
\title{
Generate covariates for drug-exposure follow-up from drug purchase records.
}
\description{
From records of drug purchase and possibly known treatment intensity,
the time since first drug use and cumulative dose at prespecified times
is computed. Optionally, lagged exposures are computed too,
i.e. cumulative exposure a prespecified time ago.
}
\usage{
gen.exp(purchase, id = "id", dop = "dop", amt = "amt", dpt = "dpt",
              fu, doe = "doe", dox = "dox",
          breaks,
         use.dpt = ( dpt \%in\% names(purchase) ),
            lags = NULL,
        push.max = Inf,
        pred.win = Inf,
         lag.dec = 1 )
}
\arguments{
  \item{purchase}{Data frame with columns \code{id}-person id,
    \code{dop} - \code{d}ate \code{o}f \code{p}urchase, \code{amt} -
    \code{am}oun\code{t} purchased, and optionally \code{dpt} -
    (\code{d}ose \code{p}er \code{t}ime) ("defined daily dose", DDD,
    that is), how much is assume  to be ingested per unit time. The
    units used for \code{dpt} is assumed to be units of \code{amt} per
    units of \code{dop}.} 
  \item{id}{Character. Name of the id variable in the data frame.}
  \item{dop}{Character. Name of the \code{d}ate \code{o}f \code{p}urchase variable in the data frame.}
  \item{amt}{Character. Name of the \code{am}oun\code{t} purchased variable in the data frame.}
  \item{dpt}{Character. Name of the \code{d}ose-\code{p}er-\code{t}ime variable in the data frame.}
  \item{fu}{Data frame with \code{f}ollow-\code{u}p period for each person, the person
    id variable must have the same name as in the \code{purchase} data frame.}
  \item{doe}{Character. Name of the \code{d}ate \code{o}f \code{e}ntry variable.}
  \item{dox}{Character. Name of the \code{d}ate \code{o}f e\code{x}it variable.}
  \item{use.dpt}{Logical: should we use information on dose per time.}
  \item{breaks}{Numerical vector of dates at which the time since
    first exposure, cumulative dose etc. are computed.}
  \item{lags}{Numerical vector of lag-times used in computing lagged cumulative
    doses.}
  \item{push.max}{Numerical. How much can purchases maximally be pushed forward in
    time. See details.}
  \item{pred.win}{The length of the window used for constructing the
    average dose per time used to compute the duration of the last purchase}
  \item{lag.dec}{How many decimals to use in the construction of
    names for the lagged exposure variables}
}

\details{
  Each purchase record is converted into a time-interval of exposure.

  If \code{use.dpt} is \code{TRUE} then the dose per time information is
  used to compute the exposure interval associated with each purchase.
  Exposure intervals are stacked, that is each interval is put after any
  previous. This means that the start of exposure to a given purchase
  can be pushed into the future. The parameter \code{push.max} indicates
  the maximally tolerated push. If this is reached by a person, the
  assumption is that some of the purchased drug is not counted in the
  exposure calculations.

  The \code{dpt} can either be a constant, basically translating the
  purchased amount into exposure time the same way for all persons, or
  it can be a vector with different treatment intensities for each
  purchase.  In any case the cumulative dose is computed taking this
  into account.

  If \code{use.dpt} is \code{FALSE} then the exposure from one purchase
  is assumed to stretch over the time to the next purchase, so we are
  effectively assuming different rates of dose per time between any two
  adjacent purchases. Moreover, with this approach, periods of
  non-exposure does not exist. Formally this approach conditions on the
  future, because the rate of consumption (the accumulation of
  cumulative exposure) is computed based on knowledge of when next
  purchase is made.

  The intention of this function is to generate covariates for a
  particular drug for the entire follow-up of each person. The reason
  that the follow-up prior to drug purchase and post-exposure is
  included is that the covariates must be defined for these periods too,
  in order to be useful for analysis of disease outcomes.

  This function is described in terme of calendar time as underlying
  time scale, because this will normally be the time scale for drug
  purchases and for entry and exit for persons. In principle the
  variables termed as dates might equally well refer to say the age
  scale, but this would then have to be true \emph{both} for the
  purchase data and the follow-up data.  
}

\value{A data frame with one record per follow-up interval between
  \code{breaks}, with columns:
\describe{
    \item{\code{id}}{person id.}
    \item{\code{dof}}{date of follow up, i.e. start of interval. Apart
  from possibly the first interval for each person, this will assume values in the set of
  the values in \code{breaks}.}
    \item{\code{Y}}{the length of interval.}
    \item{\code{tfi}}{\code{t}ime \code{f}rom first \code{i}nitiation of drug.}
    \item{\code{tfc}}{\code{t}ime \code{f}rom latest \code{c}essation of drug.}
    \item{\code{cdur}}{\code{c}umulative \code{dur}ation of the drug.}
    \item{\code{cdos}}{\code{c}umulative \code{dos}e.}
    \item{\code{ldos}}{suffixed with one value per element in
  \code{lags}, the latter giving the cumulative doses \code{lags} before
  \code{dof}.}
}
}

\author{Bendix Carstensen, \email{b@bxc.dk}.  The development of
this function was supported partly through a grant from the EFSD
(European Foundation for the Study of Diabetes), ""}

\seealso{\code{\link{Lexis}}, \code{\link{splitLexis}}}
\examples{
# Construct a simple data frame of purchases for 3 persons
# The purchase units (in variable dose) correspond to
n <- c( 10, 17, 8 )
dop <- c( 1995.2+cumsum(sample(1:4/10,n[1],replace=TRUE)),
          1997.3+cumsum(sample(1:4/10,n[2],replace=TRUE)),
          1997.3+cumsum(sample(1:4/10,n[3],replace=TRUE)) )
amt <- sample(   1:3/15, sum(n), replace=TRUE )
dpt <- sample( 15:20/25, sum(n), replace=TRUE )
dfr <- data.frame( id = rep(1:3,n),
                  dop,
                  amt = amt,
                  dpt = dpt )
round( dfr, 3 )
# Construct a simple dataframe for follow-up periods for these 3 persons
fu  <- data.frame( id = 1:3,
                  doe = c(1995,1997,1996)+1:3/4,
                  dox = c(2001,2003,2002)+1:3/5 )
round( fu, 3 )
( dpos <- gen.exp( dfr,
                    fu = fu,
                breaks = seq(1990,2015,0.5),
                  lags = 2:3/5 ) )
( xpos <- gen.exp( dfr,
                    fu = fu,
               use.dpt = FALSE,
                breaks = seq(1990,2015,0.5),
                  lags = 2:3/5 ) )

# How many relevant columns
nvar <- ncol(xpos)-3
clrs <- rainbow(nvar)

# Show how the variables relate to the follow-up time
par( mfrow=c(3,1), mar=c(3,3,1,1), mgp=c(3,1,0)/1.6, bty="n" )
for( i in unique(xpos$id) )
matplot( xpos[xpos$id==i,"dof"],
         xpos[xpos$id==i,-(1:3)],
         xlim=range(xpos$dof), ylim=range(xpos[,-(1:3)]),
         type="l", lwd=2, lty=1, col=clrs,
         ylab="", xlab="Date of follow-up" )
ytxt <- par("usr")[3:4]
ytxt <- ytxt[1] + (nvar:1)*diff(ytxt)/(nvar+2)
xtxt <- rep( sum(par("usr")[1:2]*c(0.98,0.02)), nvar )
text( xtxt, ytxt, colnames(xpos)[-(1:3)], font=2,
                  col=clrs, cex=1.5, adj=0 )
}
\keyword{data manipulation}
