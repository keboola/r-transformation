test_that("basic run", {
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

test_that("tagged files", {
    app <- RTransformation$new(file.path(KBC_DATA_DIR, '02'))
    app$readConfig()
    app$run()
    
    expect_true(file.exists(file.path(KBC_DATA_DIR, '02', 'in', 'user', 'pokus')))
    expect_true(file.exists(file.path(KBC_DATA_DIR, '02', 'in', 'user', 'model')))
    data <- read.csv(file.path(KBC_DATA_DIR, '02', 'out', 'tables', 'sample.csv'))
    expect_equal(6, data[['x']])
})

test_that("package error", {
    app <- RTransformation$new(file.path(KBC_DATA_DIR, '03'))
    app$readConfig()
    expect_error(
        app$run(), 
        'Failed to install packages: some-non-existent-package'
    )
})
