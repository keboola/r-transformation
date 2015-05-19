library(tree)
data <- read.csv("in/tables/sample.csv")
print(head(data))
data['biggerFunky'] <- data['funkyNumber']^3
write.csv(data, file = "out/tables/sample.csv", row.names = FALSE)
