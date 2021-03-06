% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/make_glm_streaming_fn.r
\name{make_glm_streaming_fn}
\alias{make_glm_streaming_fn}
\title{A streaming function for speedglm}
\usage{
make_glm_streaming_fn(data, verbose = FALSE)
}
\arguments{
\item{data}{a disk.frame}

\item{verbose}{Whether to print the status of data loading. Default to FALSE}
}
\value{
return a function, fn, that can be used as the data argument in biglm::bigglm or speedglm::shglm
}
\description{
Define a function that can be used to feed data into speedglm and biglm
}
\examples{
cars.df = as.disk.frame(cars)
streamacq = make_glm_streaming_fn(cars.df, verbose = FALSE)
m = biglm::bigglm(dist ~ speed, data = streamacq)
summary(m)
predict(m, get_chunk(cars.df, 1))
predict(m, collect(cars.df, 1))
}
\seealso{
Other Machine Learning (ML): \code{\link{dfglm}}
}
\concept{Machine Learning (ML)}
