#' Application which runs KBC transformations in R
#' @import methods
#' @import keboola.r.docker.application
#' @export RTransformation
#' @exportClass RTransformation
RTransformation <- setRefClass(
    'RTransformation',
    contains = c("DockerApplication"),
    fields = list(
        workingDir = 'character',
        scriptContent = 'character'
    ),
    methods = list(
        #' Constructor.
        #'
        #' @param Optional name of data directory, if not supplied then it
        #'  will be read from command line argument.
        #' @exportMethod
        initialize = function(args = NULL) {
           callSuper(args)
        },
        
        #' Install and load all required libraries.
        #' 
        #' @param character vector of package names to install
        installModulePackages = function(packages = c()) {
            con <- textConnection("installMessages", open = "w", local = TRUE)
            sink(con, type = c("output", "message"))                
            if (!is.null(packages) && (length(packages) > 0)) {
                # repository <- "http://cran.us.r-project.org"
                # use the czech mirror to increase speed slightly
                repository <- "http://mirrors.nic.cz/R/"
                # get only packages not yet installed
                packagesToInstall <- packages[which(!(packages %in% rownames(installed.packages())))]
                if (length(packagesToInstall) > 0) {
                    silence(
                        install.packages(
                            pkgs = packagesToInstall, 
                            lib = workingDir, 
                            repos = repository, 
                            quiet = TRUE, 
                            verbose = FALSE, 
                            dependencies = c("Depends", "Imports", "LinkingTo"), 
                            INSTALL_opts = c("--no-html")
                        )
                    )
                }
                # load all packages
                lapply(packages, function (package) {
                    silence(library(package, character.only = TRUE, quietly = TRUE))
                })
            }
            sink(NULL, type = c("output", "message"))
            logDebug(installMessages)
        },        
        
        
        #' Silence all but error output from a command.
        #' 
        #' Note: this function does nothing if the debugMode variable is set to TRUE.
        #' @return Command return value.
        silence = function(command) {
            msg.trap <- capture.output(suppressPackageStartupMessages(suppressMessages(suppressWarnings(ret <- command))))
            ret
        },


        #' Validate application configuration
        #' @exportMethod
        validate = function() {
            scr <- configData$parameters$script
            if (length(scr) > 1)  {
                scriptContent <<- paste(scr, collapse = "\n")
            } else {
                scriptContent <<- scr
            }
            if (empty(scriptContent)) {
                stop("Transformation script seems to be empty.")
            }
        },


        #' Main application entry point
        #' @exportMethod        
        run = function() {
            logInfo("Running R transformation")
            validate()
            workingDir <<- tempdir()
            if (file.exists(workingDir)) {
                unlink(workingDir, recursive = TRUE)
            }
            dir.create(workingDir, recursive = TRUE)
            # make working dir also library dir so that parallel runs do not clash with each other
            .libPaths(c(.libPaths(), workingDir)) 
            
            # install packages            
            packages <- configData$parameters$packages
            installModulePackages(packages)
            
            # save the script to file
            scriptFile = file.path(dataDir, 'script.R')
            write(file = scriptFile, x = scriptContent)
            # set data directory as current directory, so that relative paths in transformation work
            setwd(dataDir)
            
            logInfo("Running R script")
            # run the script
            wrapTryCatch({
                # load the module
                source(scriptFile)
            })
            logInfo("R script finished")
        }
    )
)
