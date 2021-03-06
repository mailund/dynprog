% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/parser.R
\name{parse_ranges}
\alias{parse_ranges}
\title{Parser for the ranges part of a specification.}
\usage{
parse_ranges(ranges)
}
\arguments{
\item{ranges}{The quosure wrapping the input to the specification.}
}
\value{
A parsed specification for ranges.
}
\description{
Parses the ranges and return a list of index
variables an the values they should iterate over. The ranges are returned as
a list with the range variables as its names and the range values as the
list components.
}
