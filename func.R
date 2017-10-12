
## function for running apache bench
## returns vector with avg,max response times
benchmark.url <- function(url, num.requests=10, concurrent.requests=1) {

    ## output file for apache benchmark
    filename <- tempfile()

    command <- sprintf("ab -s 10000 -v 3 -n %s -c %s -g %s %s", num.requests, concurrent.requests, filename, url)
    cat("Executing command ", command, "\n")
    res <- system(command, intern=T)

    ## parse resonse codes
    lines <- grep("^HTTP", res, value=T)
    response.codes <- gsub("^HTTP/1\\.0 (\\d{3}).*$", "\\1", lines)
    response.ok <- unique(response.codes)==200

    ## read apache benchmark's output file
    tab <- read.table(filename, header=T, sep='\t')

    ## we will take tha 'total time', ttime as measure
    avg <- mean(tab$ttime) / 1000
    max <- max(tab$ttime) / 1000
    
    return(c(avg=avg, max=max))
}

