\name{tvmvar}
\alias{tvmvar}
\alias{tv_var.mgm}

\title{
Estimating time-varying Mixed Vector Autoregressive Model (mVAR)
}

\description{
Estimates time-varying Mixed Vector Autoregressive Model (mVAR) via elastic-net regularized kernel smoothed Generalized Linear Models
}

\usage{
tvmvar(data, type, level, timepoints, estpoints, bandwidth, ...)
}


\arguments{
  \item{data}{
n x p data matrix.
}
  \item{type}{
p vector indicating the type of variable for each column in \code{data}: "g" for Gaussian, "p" for Poisson, "c" for categorical.
}
  \item{level}{
p vector indicating the number of categories of each variable. For continuous variables set to 1.
}
  \item{timepoints}{
A strictly increasing numeric vector of length \code{nrow(data)} indicating time points for the measurements in \code{data}. If \code{timepoints} is not specified, it is assumed that the time points are equally spaced. For details, see Haslbeck and Waldorp (2018).
}
  \item{estpoints}{
Vector indicating estimation points on interval [0, 1]. Note that we define this unit interval on the entire time series. This also includes measurements that are excluded because not enough previous measurements are available to fit the model. This ensures that the a model estimated at, for example, estimation point 0.15 is actually estimated on data close to data points around this time point. See Haslbeck and Waldorp (2018) Section 2.5 and 3.4 for a detailed description.
}
  \item{bandwidth}{
We use a gaussian density on the unit time-interval [0,1] to determine the weights for each observation at each estimated time point. The bandwidth specifies the standard deviation the Gaussian density. To get some intuition, which bandwidth results in the combination of how many data close in time one can plot Gaussians on [0,1] for different bandwidths. The bandwidth can also be selected in a data driven way using the function (see \code{bwSelect}).

}
  \item{\dots}{
Arguments passed to \code{mvar}, specifying how each single model should be estimated. See \code{?mvar}.
}
}


\details{
Estimates a sequence of mVAR models at the time points specified at the locations specified via \code{estpoints}. \code{tvmvar()} is a wrapper around \code{mvar()} and estimates a series of MGM with different weightings which are defined by the estimation locations in \code{estpoints} and the banwdith parameter specified in \code{bandwidth}. For details see Haslbeck and Waldorp (2018)


}
\value{
A list with the following entries:


\item{call}{
Contains all provided input arguments. If \code{saveData = TRUE}, it also contains the data.
}


\item{wadj}{
A p x p x n_lags x S array, where n_lags is the number of specified lags in \code{lags} (see \code{?mvar}) and S is the number of estimation points specified in \code{estpoints}. For instance, wadj[1, 2, 1, 10] is the cross-lagged predicting variable 1 at time point t by variable 2 at time point t - z, where z is specified by the first lag specified in \code{lags} (see \code{?mvar}), in the model estimated at estimation point 10.}

\item{signs}{ Has the same structure as \code{wadj} and specifies the signs corresponding to the parameters in \code{wadj}, if defined. 1/-1 indicate positive and negative relationships, respectively. 0 indicates that no sign is defined, which is the case for interactions that involve a categorical variable where an interaction can have more than one parameter. If \code{binarySign = TRUE}, a sign is calculated for interactions between binary variables and binary and continuous variables, where the interaction is still defined by one parameter and hence a sign can be specified. \code{NA} indicates that the corresponding parameter in \code{wadj} is zero. See also \code{?mvar}.
}

\item{intercepts}{
A list with S entries, where S is the number of estimated time points. Each entry of that list contains a list p entries with the intercept/thresholds for each node in the network. In case a given node is categorical with m categories, there are m thresholds for this variable.
}

\item{tvmodels}{
Contains the mVAR model estimated by \code{mvar()} at each time point specified via \code{estpoints}. See \code{?mvar} for a detailed description of this output.
}

}


\references{

Haslbeck, J. M. B., & Waldorp, L. J. (2020). mgm: Estimating time-varying Mixed Graphical Models in high-dimensional Data. Journal of Statistical Software, 93(8), pp. 1-46. DOI: 10.18637/jss.v093.i08

}

\author{
Jonas Haslbeck <jonashaslbeck@gmail.com>
}



\examples{

\dontrun{


## We set up the same model as in the example of mvar(), but
## specify one time-varying parameter, and try to recover it with
## tvmvar()

# a) Specify time-varying VAR model

p <- 6 # Six variables
type <- c("c", "c", "c", "c", "g", "g") # 4 categorical, 2 gaussians
level <- c(2, 2, 4, 4, 1, 1) # 2 categoricals with 2 categories, 2 with 5
max_level <- max(level)
n_timepoints <- 4000

lags <- c(1, 3, 9) # include lagged effects of order 1, 3, 9
n_lags <- length(lags)

# Specify thresholds
thresholds <- list()
thresholds[[1]] <- matrix(0, ncol=level[1], nrow=n_timepoints)
thresholds[[2]] <- matrix(0, ncol=level[2], nrow=n_timepoints)
thresholds[[3]] <- matrix(0, ncol=level[3], nrow=n_timepoints)
thresholds[[4]] <- matrix(0, ncol=level[4], nrow=n_timepoints)
thresholds[[5]] <- matrix(0, ncol=level[5], nrow=n_timepoints)
thresholds[[6]] <- matrix(0, ncol=level[6], nrow=n_timepoints)

# Specify standard deviations for the Gaussians
sds <- matrix(NA, ncol=p, nrow=n_timepoints)
sds[, 5:6] <- 1

# Create coefficient array
coefarray <- array(0, dim=c(p, p, max_level, max_level, n_lags, n_timepoints))

# a.1) interaction between continuous 5<-6, lag=3
coefarray[5, 6, 1, 1, 2, ] <- seq(0, .4, length = n_timepoints) # only time-varying parameter
# a.2) interaction between 1<-3, lag=1
m1 <- matrix(0, nrow=level[2], ncol=level[4])
m1[1,1:2] <- 1
m1[2,3:4] <- 1
coefarray[1, 3, 1:level[2], 1:level[4], 1, ] <- m1 # constant across time
# a.3) interaction between 1<-5, lag=9
coefarray[1, 5, 1:level[1], 1:level[5], 3, ] <- c(0, 1) # constant across time


# b) Sample
set.seed(1)
dlist <- tvmvarsampler(coefarray = coefarray,
                       lags = lags,
                       thresholds = thresholds,
                       sds = sds,
                       type = type,
                       level = level,
                       pbar = TRUE)

# c.1) Recover: stationary
set.seed(1)
mvar_obj <- mvar(data = dlist$data,
                 type = type,
                 level = level,
                 lambdaSel = "CV",
                 lags = c(1, 3, 9),
                 signInfo = FALSE)

# Did we recover the true parameters?
mvar_obj$wadj[5, 6, 2] # cross-lagged effect of 6 on 5 over lag lags[2] (lag 3)
mvar_obj$wadj[1, 3, 1] # cross-lagged effect of 3 on 1 over lag lags[1] (lag 1)
mvar_obj$wadj[1, 5, 3] # cross-lagged effect of 1 on 5 over lag lags[3] (lag 9)


# c.2) Recover: time-varying
set.seed(1)
mvar_obj <- tvmvar(data = dlist$data,
                   type = type,
                   level = level,
                   estpoints = seq(0, 1, length=10),
                   bandwidth = .15,
                   lambdaSel = "CV",
                   lags = c(1, 3, 9),
                   signInfo = FALSE)

# Did we recover the true parameters?
mvar_obj$wadj[5, 6, 2, ] # true sort of recovered
mvar_obj$wadj[1, 3, 1, ] # yes
mvar_obj$wadj[1, 5, 3, ] # yes

# Plotting parameter estimates over time
plot(mvar_obj$wadj[5, 6, 2, ], 
     type="l", ylim=c(-.2,.7), 
     lwd=2, ylab="Parameter value", xlab="Estimation points")
lines(mvar_obj$wadj[1, 3, 1, ], col="red", lwd=2)
lines(mvar_obj$wadj[1, 5, 3, ], col="blue", lwd=2)
legend("bottomright", c("5 <-- 6", "1 <-- 3", "1 <-- 5"), 
       lwd = c(2,2,2), col=c("black", "red", "blue"))


# d) Predict values / compute nodewise error

mvar_pred_w <- predict.mgm(object=mvar_obj,
                           data=dlist$data,
                           tvMethod = "weighted")

mvar_pred_cM <- predict.mgm(object=mvar_obj,
                            data=dlist$data,
                            tvMethod = "closestModel")

mvar_pred_w$errors
mvar_pred_cM$errors

# For more examples see https://github.com/jmbh/mgmDocumentation


}

}



