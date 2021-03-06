% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/zip_to_disk.frame.r
\name{zip_to_disk.frame}
\alias{zip_to_disk.frame}
\title{`zip_to_disk.frame` is used to read and convert every CSV file within the zip
file to disk.frame format}
\usage{
zip_to_disk.frame(zipfile, outdir, ..., validation.check = FALSE,
  overwrite = TRUE)
}
\arguments{
\item{zipfile}{The zipfile}

\item{outdir}{The output directory for disk.frame}

\item{...}{passed to fread}

\item{validation.check}{should the function perform a check at the end to check for validity of output. It can detect issues with conversion}

\item{overwrite}{overwrite output directory}
}
\value{
a list of disk.frame
}
\description{
`zip_to_disk.frame` is used to read and convert every CSV file within the zip
file to disk.frame format
}
\examples{
# create a zip file containing a csv
csvfile = tempfile(fileext = ".csv")
write.csv(cars, csvfile)
zipfile = tempfile(fileext = ".zip")
zip(zipfile, csvfile)

# read every file and convert it to a disk.frame
zip.df = zip_to_disk.frame(zipfile, tempfile(fileext = ".df"))

# there is only one csv file so it return a list of one disk.frame
zip.df[[1]]

# clean up
unlink(csvfile)
unlink(zipfile)
delete(zip.df[[1]])
}
\seealso{
Other ingesting data: \code{\link{csv_to_disk.frame}}
}
\concept{ingesting data}
