#' Application which runs KBC transformations in R
#' @import methods
#' @import keboola.r.docker.application
#' @export RTransformation
#' @exportClass RTransformation
RTransformation <- setRefClass(
    'RTransformation',
    contains = c("DockerApplication"),
    fields = list(
        scriptContent = 'character',
        tags = 'character',
        packages = 'character'
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
        
        silence = function(command) {
            "Silence all but error output from a command.
            \\subsection{Parameters}{\\itemize{
            \\item{\\code{command} Arbitrary command.}
            }}
            \\subsection{Return Value}{Command return value}"
            msg.trap <- capture.output(suppressPackageStartupMessages(suppressMessages(suppressWarnings(ret <- command))))
            ret
        },
        
        installModulePackages = function() {
            "Install and load all required libraries.
            \\subsection{Return Value}{TRUE}"
            if (!interactive()) {
                con <- textConnection("installMessages", open = "w", local = TRUE)
                sink(con, type = c("output", "message"))
            }
            if (!is.null(.self$packages) && (length(.self$packages) > 0)) {
                # use the czech mirror to increase speed slightly
                # get only packages not yet installed
                packagesToInstall <- .self$packages[which(!(.self$packages %in% rownames(installed.packages())))]
                if (length(packagesToInstall) > 0) {
                    .self$logInfo(paste0("Installing packages: ", paste(packagesToInstall, collapse = ', ')))
                    .self$silence(
                        install.packages(
                            pkgs = packagesToInstall, 
                            quiet = TRUE, 
                            verbose = FALSE, 
                            dependencies = c("Depends", "Imports", "LinkingTo"), 
                            INSTALL_opts = c("--no-html")
                        )
                    )
                }
                # load all packages
                lapply(.self$packages, function (package) {
                    if (!.self$silence(library(package, character.only = TRUE, quietly = TRUE, logical.return = TRUE))) {
                        stop(paste0("Failed to load package: ", package))
                    }
                })
            }
            if (!interactive()) {
                sink(NULL, type = c("output", "message"))
            }
            .self$logDebug(installMessages)
        },        
        
        validate = function() {
            "Validate application configuration. 
            \\subsection{Return Value}{TRUE}"
            
            # check for surplus parameters
            enteredParameters <- names(configData$parameters)
            knownParameters <- c('script', 'tags', 'packages')
            surplusParameters <- enteredParameters[which(!(enteredParameters %in% knownParameters))]
            if (length(surplusParameters) > 0) {
                .self$logError(paste0("Unknown parameters: ", paste(surplusParameters, collapse = ', ')))
            }
            
            # R script must be non-empty
            scr <- configData$parameters$script
            if (length(scr) > 1)  {
                scriptContent <<- paste(scr, collapse = "\n")
            } else {
                scriptContent <<- scr
            }
            if (empty(scriptContent)) {
                stop("Transformation script seems to be empty.")
            }
            
            print(configData$parameters$tags)
            if (empty(configData$parameters$tags)) {
                tags <<- character()
            } else {
                tags <<- configData$parameters$tags
            }
            
            if (empty(configData$parameters$packages)) {
                packages <<- character()
            } else {
                packages <<- configData$parameters$packages
            }
            
            TRUE
        },

        prepareTaggedFiles = function() {
            "When supplied a list of tags, select input files with the given tags and prepare the 
            most recent file of those into a /user/ folder
            \\subsection{Parameters}{\\itemize{
            \\item{\\code{packages} Character vector of tag names.}
            }}
            \\subsection{Return value}{TRUE}"
            dir.create(file.path(.self$dataDir, 'in', 'user'))
            inDirectory <- file.path(.self$dataDir, 'in', 'files')
            files <- list.files(inDirectory, pattern = '^.*\\.manifest$', full.names = FALSE)
            for (tag in .self$tags) {
                lastTime <- 0
                lastManifest <- ''
                for (file in files) {
                    .self$logInfo(paste0("Reading manifest: ", file))
                    manifestPath <- file.path(.self$dataDir, 'in', 'files', file)
                    manifestData <- readChar(manifestPath, file.info(manifestPath)$size)
                    manifest <- jsonlite::fromJSON(manifestData)
                    if (tag %in% manifest$tags) {
                        fileTime <- strptime(manifest$created, '%Y-%m-%dT%H:%M:%S%z')
                        if (fileTime > lastTime) {
                            lastTime <- fileTime
                            lastManifest <- file
                        }
                    }
                }
                if (lastManifest == '') {
                    stop(paste0("No files were found for tag: ", tag))
                } else {
                    # remove .manifest suffix
                    fileName = substr(file, start = 0, stop = nchar(file) - 9)
                    print(paste0("file: ", fileName))
                    file.copy(file.path(.self$dataDir, 'in', 'files', fileName), 
                            file.path(.self$dataDir, 'in', 'user', tag))
                    file.copy(file.path(.self$dataDir, 'in', 'files', paste0(fileName, '.manifest')), 
                              file.path(.self$dataDir, 'in', 'user', paste0(tag, '.manifest')))
                }
            }
        },

        
        run = function() {
            "Main application entry point.
            \\subsection{Return Value}{TRUE}"
            .self$logInfo("Initializing R transformation")
            .self$validate()
            .self$prepareTaggedFiles()

            # install packages            
            .self$logDebug("Installing packages")
            .self$installModulePackages()
            
            # save the script to file
            scriptFile = file.path(dataDir, 'script.R')
            .self$logInfo(paste0("Creating script: ", scriptFile))
            write(file = scriptFile, x = scriptContent)
            # set data directory as current directory, so that relative paths in transformation work
            setwd(.self$dataDir)
            
            .self$logInfo("Running R script")
            # run the script
            .self$wrapTryCatch({
                # load the module
                source(scriptFile)
            })
            .self$logInfo("R script finished")
        }
    )
)
