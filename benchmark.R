
## read in URLs
urls <- scan('urls.txt', what='character')

concurrent.requests <- c(1, 10, 100)

## initialise plotting device
jpeg("benchmark-nba.jpg", width=30, height=20, units='cm', res=300)
par(mfrow=c(3, 1))

for (url in urls) {

    ##make data frame with results
    avg.times <- data.frame(ctime=numeric(0), dtime=numeric(0), ttime=numeric(0), wait=numeric(0))
    ## sd.times <- data.frame()
    
    for (num.req in concurrent.requests) {

        ## output file for gnu benchmark
        filename <- tempfile()

        ## construct apache benchmark command and execute        
        command <- sprintf("ab -s 10000 -n %s -c %s -g %s %s", num.req, num.req, filename, url)
        cat("Executing command ", command, "\n")
        res <- system(command, intern=T)

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
    plot(log10(concurrent.requests), avg.times$ttime, col='red', ylim=c(0, max(avg.times$ttime)),
         lwd=2, type='b', main=title, xlab="log10(concurrent requests)", ylab="average response time (s)")
    lines(log10(concurrent.requests), avg.times$ctime, col='blue', type='b')
    lines(log10(concurrent.requests), avg.times$dtime, col='orange', type='b')
    lines(log10(concurrent.requests), avg.times$wait, col='green', type='b')
    legend('bottomright', c('total', 'conncection', 'processing', 'wait'), fill=c('red', 'blue', 'orange', 'green'), bty='n')        
}
dev.off()
