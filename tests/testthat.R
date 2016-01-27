library(testthat)
Sys.setenv("R_TESTS" = "")

# so that the tests pass on Travis 
.libPaths(c(.libPaths(), KBC_DATA_DIR)) 

KBC_DATA_DIR = '../data/'

# override with config if any
if (file.exists("config.R")) {
    source("config.R")
}

# override with environment if any
if (nchar(Sys.getenv("KBC_DATA_DIR")) > 0) {
    KBC_DATA_DIR <- Sys.getenv("KBC_DATA_DIR")  
}

test_check("keboola.r.transformation")
