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

test_that("tagged files 2", {
    app <- RTransformation$new(file.path(KBC_DATA_DIR, '04'))
    app$readConfig()
    app$run()
    
    expect_true(file.exists(file.path(KBC_DATA_DIR, '04', 'in', 'user', 'FirstTag')))
    expect_true(file.exists(file.path(KBC_DATA_DIR, '04', 'in', 'user', 'SecondTag')))
    expect_true(file.exists(file.path(KBC_DATA_DIR, '04', 'in', 'user', 'ThirdTag')))
    data <- read.csv(file.path(KBC_DATA_DIR, '04', 'out', 'tables', 'sample.csv'), stringsAsFactors = FALSE)
    expect_equal('firstsecondthird', data[['x']])
})