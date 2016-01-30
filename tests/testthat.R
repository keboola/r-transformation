library(testthat)
Sys.setenv("R_TESTS" = "")

KBC_DATA_DIR = '../data/'

# override with config if any
if (file.exists("config.R")) {
    source("config.R")
}

# override with environment if any
if (nchar(Sys.getenv("KBC_DATA_DIR")) > 0) {
    KBC_DATA_DIR <- Sys.getenv("KBC_DATA_DIR")  
}

# so that the tests pass on Travis 
.libPaths(c(.libPaths(), KBC_DATA_DIR))
local({
    r <- getOption("repos")
    r["CRAN"] <- "http://cran.r-project.org" 
    options(repos = r)
})

test_check("keboola.r.transformation")
