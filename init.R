library('devtools')

# install the transformation application ancestors
devtools::install_github('keboola/r-application', ref = "master", force = TRUE)
devtools::install_github('keboola/r-docker-application', ref = "master", force = TRUE)
# install the transformation application which is present in local directory

ip <- as.data.frame(installed.packages()[,c(1,3:4)])
rownames(ip) <- NULL
ip <- ip[is.na(ip$Priority),1:2,drop=FALSE]
print(ip, row.names=FALSE)

    wrapTryCatch = function(expr, silentSuccess = FALSE, stopIsFatal = TRUE) {
            logger <- function(obj) {
                # Change behaviour based on type of message
                level = sapply(class(obj), switch, debug="DEBUG", message="INFO", warning="WARN", caughtError = "ERROR",
                               error=if (stopIsFatal) "FATAL" else "ERROR", "")
                level = c(level[level != ""], "ERROR")[1]
                simpleMessage = switch(level, DEBUG=,INFO=TRUE, FALSE)
                quashable = switch(level, DEBUG=,INFO=,WARN=TRUE, FALSE)
                
                # Format message
                time  = format(Sys.time(), "%Y-%m-%d %H:%M:%OS3")
                txt   = conditionMessage(obj)
                if (!simpleMessage) txt = paste(txt, "\n", sep="")
                msg = paste(time, level, txt, sep=" ")
                calls = sys.calls()
                calls = calls[1:length(calls)-1]
                trace = limitedLabels(c(calls, attr(obj, "calls")))
                if (!simpleMessage && length(trace) > 0) {
                    trace = trace[length(trace):1]
                    msg = paste(msg, "  ", paste("at", trace, collapse="\n  "), "\n", sep="")
                }
                
                # Output message
                if (silentSuccess && !hasFailed && quashable) {
                    print(msg)
                    if (level == "WARN") print(msg)
                } else {
                    if (silentSuccess && !hasFailed) {
                        print(messages)
                    }
                    print(msg)
                }
                
                # Muffle any redundant output of the same message
                optionalRestart = function(r) { res = findRestart(r); if (!is.null(res)) invokeRestart(res) }
                optionalRestart("muffleMessage")
                optionalRestart("muffleWarning")
            }
            vexpr = withCallingHandlers(
                withVisible(expr),
                debug=logger, message=logger, warning=logger, caughtError=logger, error=logger
            )
            if (silentSuccess && !hasFailed) {
                print(warnings)
            }
            if (vexpr$visible) vexpr$value else invisible(vexpr$value)
    }
    
    wrapTryCatch({    
devtools::install('.') 
})
    