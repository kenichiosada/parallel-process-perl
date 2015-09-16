## Performance benchmark of parallel processing in Perl

Testing how Parallel::ForkManager can save time in batch process.  

Benchmark is performed on:   
  * MacBook 2.9GHz Core i7 8GB memory  
  * Perl 5.18.2 (perlbrew)  


### Simple

Executing subroutine that sleeps 1 second.   
Compare execution time to complete sleeping 10 times. 

Result:  

    Benchmark: timing 1 iterations of Parallel, Procedural...
    Parallel:  6 wallclock secs ( 0.00 usr  0.00 sys +  0.01 cusr  0.02 csys =  0.03 CPU) @ 33.33/s (n=1)
    Procedural: 10 wallclock secs ( 0.00 usr +  0.00 sys =  0.00 CPU)

### Fibonacci

Calculate total of 10000 fibonacci numbers.  
Parallel processing uses 8 processes, calculating 1250 times each.  

Result:  

    Benchmark: timing 1 iterations of Parallel, Procedural...
    Parallel: 34 wallclock secs ( 0.00 usr  0.01 sys + 120.32 cusr  0.20 csys = 120.53 CPU) @  0.01/s (n=1)
    Procedural: 64 wallclock secs (64.07 usr +  0.03 sys = 64.10 CPU) @  0.02/s (n=1)
    
               s/iter   Parallel Procedural
    Parallel      121         --       -47%
    Procedural   64.1        88%         --
    
    Total1:  67650000
    Total2:  67650000

### Array

Process CSV data and get summary of data. I use restaurant information dataset provided by [Livedoor](https://github.com/livedoor/datasets), data which lists over 200,000 rows of restaurant in Japan. The script will gather number of restaurant per prefecture and show top 5.  

Result: 

    Benchmark: timing 10 iterations of Parallel, Procedural...
    Parallel: 75 wallclock secs (67.65 usr  7.38 sys + 30.96 cusr 11.10 csys = 117.09 CPU) @  0.09/s (n=10)
    Procedural: 52 wallclock secs (49.61 usr +  1.72 sys = 51.33 CPU) @  0.19/s (n=10)

               s/iter   Parallel Procedural
    Parallel     11.7         --       -56%
    Procedural   5.13       128%         --

    #1 Prefecture ID: 13 (64565 restaurants)
    #2 Prefecture ID: 27 (16483 restaurants)
    #3 Prefecture ID: 14 (13873 restaurants)
    #4 Prefecture ID: 23 (10372 restaurants)
    #5 Prefecture ID: 28 (9426 restaurants)

### Elasticsearch

Insert CSV data from previous example into Elasticsearch using [Index API](https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-index_.html)  

Ref: [ElasticsearchのインストールとCSVからのデータ挿入](http://easyramble.com/install-elasticsearch-import-data.html)  

Result:  

    Parallel: 1587 wallclock secs ( 5.01 usr  0.45 sys + 807.05 cusr 535.77 csys = 1348.28 CPU) @  0.00/s (n=1)
    Procedural: 1808 wallclock secs (13.35 usr 98.09 sys + 609.71 cusr 410.82 csys = 1131.97 CPU) @  0.00/s (n=1)

               s/iter   Parallel Procedural
    Parallel     1348         --       -16%
    Procedural   1132        19%         --

Note) I only processed 100,000 rows for this example.


