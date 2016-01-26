library('devtools')

# install the transformation application ancestors
install_github('keboola/r-application', ref = "master")
install_github('keboola/r-docker-application', ref = "master")
# install the transformation application which is present in local directory
install('.') 
