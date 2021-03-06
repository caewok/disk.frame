% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/merge.disk.frame.r
\name{merge.disk.frame}
\alias{merge.disk.frame}
\title{Merge function for disk.frames}
\usage{
\method{merge}{disk.frame}(x, y, by, outdir = tempfile(fileext = ".df"),
  ..., merge_by_chunk_id = FALSE, overwrite = FALSE)
}
\arguments{
\item{x}{a disk.frame}

\item{y}{a disk.frame or data.frame}

\item{by}{the merge by keys}

\item{outdir}{The output directory for the disk.frame}

\item{...}{passed to merge and map.disk.frame}

\item{merge_by_chunk_id}{if TRUE then only chunks in df1 and df2 with the same chunk id will get merged}

\item{overwrite}{overwrite the outdir or not}
}
\description{
Merge function for disk.frames
}
\examples{
b = as.disk.frame(data.frame(a = 51:150, b = 1:100))
d = as.disk.frame(data.frame(a = 151:250, b = 1:100))
bd.df = merge(b, d, by = "b")

# clean up cars.df
delete(b)
delete(d)
delete(bd.df)
}
