## Performance benchmark of parallel processing in Perl

Testing how Parallel::ForkManager can save time in batch process.  


### Simple

Executing subroutine that sleeps 1 second.   
Compare execution time to complete sleeping 10 times. 

Result:  

    Benchmark: timing 1 iterations of Parallel, Procedural...
    Parallel:  6 wallclock secs ( 0.00 usr  0.00 sys +  0.01 cusr  0.02 csys =  0.03 CPU) @ 33.33/s (n=1)
    Procedural: 10 wallclock secs ( 0.00 usr +  0.00 sys =  0.00 CPU)


