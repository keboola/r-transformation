library(testthat)

# default values
DATA_DIR = 'tests/data'

# override with config if any
if (file.exists("config.R")) {
    source("config.R")
}

# override with environment if any
if (nchar(Sys.getenv("DATA_DIR")) > 0) {
    DATA_DIR <- Sys.getenv("DATA_DIR")  
}

test_check("keboola.r.transformation")
