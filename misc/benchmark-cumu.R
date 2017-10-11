##30076 : v9
##31932 : v10

num.concurrent.requests <- 100

## read in URLs
urls <- scan('urls.txt', what='character')
## 'Commented out' urls begin with a '#', filter them out! 
urls <- urls[!grepl("^#", urls)]

## initialise plotting device
filename <- paste0("benchmark-concurrent-", num.concurrent.requests, ".pdf")
pdf(filename)

## title page with date
server <- sub("(^.*v2/).*", "\\1", urls[1])
plot(c(0, 1), c(0, 1), ann = F, bty = 'n', type = 'n', xaxt = 'n', yaxt = 'n')
text(x = 0.5, y = 0.7, paste("NBA benchmark test\n"), cex = 3, col = "black")
text(x = 0.5, y = 0.5, paste("Server: ", server), cex = 1.8, col = "black")
text(x = 0.5, y = 0.3, paste(format(Sys.time(), "%a %b %d %Y\n%H:%M:%S")), cex = 1.8, col = "black")

for (url in urls) {
    ## output file for gnu benchmark
    filename <- tempfile()
    
    ## construct apache benchmark command and execute        
    command <- sprintf("ab -s 100000 -v 3 -n %s -c %s -e %s %s", num.concurrent.requests, num.concurrent.requests, filename, url)
    cat("Executing command ", command, "\n")
    res <- system(command, intern=T)

    ## get response codes
    lines <- grep("^HTTP", res, value=T)
    response.codes <- gsub("^HTTP/1\\.0 (\\d{3}).*$", "\\1", lines)
    cat("Response codes : ", unique(response.codes), "\n")
    
    ## read apache benchmark's output file
    tab <- read.table(filename, sep=',', skip=1)
    percentage.served <- tab[,1]
    time <- tab[,2]
    
    title <- sub("^.*v2/", "", url)        
    ## title <- gsub("(.{30})", "\\1\n", title)
    plot(tab, xlab="% of requests served", ylab="time (ms)", cex.lab=1.5, cex=1.5, main=title, col=ifelse(response.codes==200, "black", "red"), pch=ifelse(response.codes==200, 1, 25))
##    recover()
}
dev.off()
