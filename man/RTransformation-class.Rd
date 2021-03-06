% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/keboola.r.transformation.R
\docType{class}
\name{RTransformation-class}
\alias{RTransformation-class}
\alias{RTransformation}
\title{Application which runs KBC transformations in R}
\description{
Application which runs KBC transformations in R
}
\section{Methods}{

\describe{
\item{\code{initialize(args = NULL)}}{Constructor.
\subsection{Parameters}{\itemize{
\item{\code{args} Optional name of data directory, if not supplied then it
will be read from command line argument or environment KBC_DATADIR.}
}}
\subsection{Return Value}{Response body - either list or string in case the body cannot be parsed as JSON.}}

\item{\code{installModulePackages()}}{Install and load all required libraries.
\subsection{Return Value}{TRUE}}

\item{\code{prepareTaggedFiles()}}{When supplied a list of tags, select input files with the given tags and prepare the 
most recent file of those into a /user/ folder
\subsection{Parameters}{\itemize{
\item{\code{packages} Character vector of tag names.}
}}
\subsection{Return value}{TRUE}}

\item{\code{run()}}{Main application entry point.
\subsection{Return Value}{TRUE}}

\item{\code{silence(command)}}{Silence all but error output from a command.
\subsection{Parameters}{\itemize{
\item{\code{command} Arbitrary command.}
}}
\subsection{Return Value}{Command return value}}

\item{\code{validate()}}{Validate application configuration. 
\subsection{Return Value}{TRUE}}
}}

