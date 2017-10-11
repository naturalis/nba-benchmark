
## read in URLs
urls <- scan('urls.txt', what='character')
## 'Commented out' urls begin with a '#', filter them out! 
urls <- urls[!grepl("^#", urls)]

## concurrent.requests <- c(5, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100)
concurrent.requests <- c(40, 45, 50, 55, 60, 65, 70, 75, 80)

## initialise plotting device
pdf("benchmark-v2.9-oct-05.pdf")

## title page with date
server <- sub("(^.*v2/).*", "\\1", urls[1])
plot(c(0, 1), c(0, 1), ann = F, bty = 'n', type = 'n', xaxt = 'n', yaxt = 'n')
text(x = 0.5, y = 0.7, paste("NBA benchmark test\n"), cex = 3, col = "black")
text(x = 0.5, y = 0.5, paste("Server: ", server), cex = 1.8, col = "black")
text(x = 0.5, y = 0.3, paste(format(Sys.time(), "%a %b %d %Y\n%H:%M:%S")), cex = 1.8, col = "black")


for (url in urls) {

    ##make data frame with results
    avg.times <- data.frame(ctime=numeric(0), dtime=numeric(0), ttime=numeric(0), wait=numeric(0))
    ## sd.times <- data.frame()

    response.ok <- vector()
    for (num.req in concurrent.requests) {

        ## output file for gnu benchmark
        filename <- tempfile()

        num.rep <- num.req
        ## construct apache benchmark command and execute        
        command <- sprintf("ab -s 10000 -v 3 -n %s -c %s -g %s %s", num.rep, num.req, filename, url)
        cat("Executing command ", command, "\n")
        res <- system(command, intern=T)
        
        ## parse resonse codes
        lines <- grep("^HTTP", res, value=T)
        response.codes <- gsub("^HTTP/1\\.0 (\\d{3}).*$", "\\1", lines)
        response.ok <- c(response.ok, unique(response.codes)==200)
        
        cat("Response codes : ", unique(response.codes), "\n")        
        
        ## read apache benchmark's output file
        tab <- read.table(filename, header=T, sep='\t')

        
        ## calc mean and sd and add to results & convert to seconds!
        avg <- colMeans(tab[,c('ctime', 'dtime', 'ttime', 'wait')]) / 1000       
        ## sds <- apply(tab[,c('ctime', 'dtime', 'ttime', 'wait')], 2, sd)
        avg.times <- rbind(avg.times, avg)
        ## sd.times <- rbind(sd.times, sds)                
    }
    ## Colnames got lost!!
    colnames(avg.times) <- c('ctime', 'dtime', 'ttime', 'wait')

    ## plot results
    title <- sub("^.*v2/", "", url)
    plot(concurrent.requests, avg.times$ttime, col='red', ylim=c(0, max(avg.times$ttime)),
         lwd=2, type='b', main=title, xlab="concurrent requests", ylab="average response time (s)", pch=ifelse(response.ok, 1, 25))
    lines(concurrent.requests, avg.times$ctime, col='blue', type='b')
    lines(concurrent.requests, avg.times$dtime, col='orange', type='b')
    lines(concurrent.requests, avg.times$wait, col='green', type='b')
    legend('bottomright', c('total', 'conncection', 'processing', 'wait'), fill=c('red', 'blue', 'orange', 'green'), bty='n')        
}
dev.off()
