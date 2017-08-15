# nba-benchmark
Benchmark NBA using Apache bench and visualise results.

## Prerequisites
 * Installation of [Apache bench](https://httpd.apache.org/docs/2.4/programs/ab.html)
 * Installation of R
 
## Running
URLs to be benchmarked are listed in `urls.txt`. Start benchmark by executing the script `benchmark.R` from within an R shell. Per default, concurrent requests of batch sizes 1, 10, and 100 are done one after another. Results are plotted into a file named `benchmark-nba.jpg`. If more URLs are added to `urls.txt`, the script might have to be adjusted concerning plot window size etc.
