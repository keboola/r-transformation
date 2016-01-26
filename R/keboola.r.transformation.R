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
        initialize = function(args = NULL) {
            "Constructor.
            \\subsection{Parameters}{\\itemize{
            \\item{\\code{args} Optional name of data directory, if not supplied then it
                will be read from command line argument.}
            }}"            
           callSuper(args)
        },
        
        installModulePackages = function(packages = c()) {
            "Install and load all required libraries.
            \\subsection{Parameters}{\\itemize{
            \\item{\\code{packages} Character vector of package names.}
            }}"            
            con <- textConnection("installMessages", open = "w", local = TRUE)
            sink(con, type = c("output", "message"))                
            if (!is.null(packages) && (length(packages) > 0)) {
                # repository <- "http://cran.us.r-project.org"
                # use the czech mirror to increase speed slightly
                repository <- "http://mirrors.nic.cz/R/"
                # get only packages not yet installed
                packagesToInstall <- packages[which(!(packages %in% rownames(installed.packages())))]
                if (length(packagesToInstall) > 0) {
                    # silence(
                        install.packages(
                            pkgs = packagesToInstall, 
                            lib = workingDir, 
                            repos = repository, 
                            quiet = TRUE, 
                            verbose = FALSE, 
                            dependencies = c("Depends", "Imports", "LinkingTo"), 
                            INSTALL_opts = c("--no-html")
                        )
                   # )
                }
                # load all packages
                lapply(packages, function (package) {
                    silence(library(package, character.only = TRUE, quietly = TRUE))
                })
            }
            sink(NULL, type = c("output", "message"))
            logDebug(installMessages)
        },        
        
        silence = function(command) {
            "Silence all but error output from a command.
            \\subsection{Parameters}{\\itemize{
            \\item{\\code{command} Arbitrary command.}
            }}
            \\subsection{Return Value}{Command return value}"
            msg.trap <- capture.output(suppressPackageStartupMessages(suppressMessages(suppressWarnings(ret <- command))))
            ret
        },

        validate = function() {
            "Validate application configuration. 
            \\subsection{Return Value}{TRUE}"
            scr <- configData$parameters$script
            if (length(scr) > 1)  {
                scriptContent <<- paste(scr, collapse = "\n")
            } else {
                scriptContent <<- scr
            }
            if (empty(scriptContent)) {
                stop("Transformation script seems to be empty.")
            }
            TRUE
        },

        run = function() {
            "Main application entry point.
            \\subsection{Return Value}{TRUE}"
            logInfo("Running R transformation")
            validate()
            logInfo(paste0("Clearing working directory: ", workingDir))
            workingDir <<- tempdir()
            if (file.exists(workingDir)) {
                unlink(workingDir, recursive = TRUE)
            }
            dir.create(workingDir, recursive = TRUE)
            # make working dir also library dir so that parallel runs do not clash with each other
            .libPaths(c(.libPaths(), workingDir)) 
            
            logInfo("Installing packages")
            # install packages            
            packages <- configData$parameters$packages
            installModulePackages(packages)
            
            # save the script to file
            scriptFile = file.path(dataDir, 'script.R')
            logInfo(paste0("Creating script: "), scriptFile)
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
