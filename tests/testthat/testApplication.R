test_that("validate", {
    app <- RTransformation$new(file.path(KBC_DATA_DIR, '01'))
    app$readConfig()
    app$run()
    
    expect_true(file.exists(file.path(KBC_DATA_DIR, '01', 'out', 'tables')))
    data <- read.csv(file.path(KBC_DATA_DIR, '01', 'out', 'tables', 'sample.csv'))
    expect_equal(
        data[['funkyNumber']]^3,
        data[['biggerFunky']]
    )
})