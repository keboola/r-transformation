suppressMessages(library('keboola.r.transformation', quiet = TRUE))

# run it
app <- RTransformation$new()
ret <- app$readConfig()
ret <- app$run()