## Performance benchmark of parallel processing in Perl

Testing how Parallel::ForkManager can save time in batch process.  


### Simple

Executing subroutine that sleeps 1 second.   
Compare execution time to complete sleeping 10 times. 

Result:  

    Benchmark: timing 1 iterations of Parallel, Procedural...
    Parallel:  6 wallclock secs ( 0.00 usr  0.00 sys +  0.01 cusr  0.02 csys =  0.03 CPU) @ 33.33/s (n=1)
    Procedural: 10 wallclock secs ( 0.00 usr +  0.00 sys =  0.00 CPU)

### Fibonacci

Calculate total of 10000 fibonacci numbers.  
Parallel processing uses 8 processes, calculatin 1250 times each.  

Result:  

    Benchmark: timing 1 iterations of Parallel, Procedural...
    Parallel: 34 wallclock secs ( 0.00 usr  0.01 sys + 120.32 cusr  0.20 csys = 120.53 CPU) @  0.01/s (n=1)
    Procedural: 64 wallclock secs (64.07 usr +  0.03 sys = 64.10 CPU) @  0.02/s (n=1)
    
               s/iter   Parallel Procedural
    Parallel      121         --       -47%
    Procedural   64.1        88%         --
    
    Total1:  67650000
    Total2:  67650000
