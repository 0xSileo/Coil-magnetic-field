This repo was initially intended to provide a "learning in public" approach for Rust, but ended up becoming a "Optimise the computation of the magnetic field of a coil" repo. The values in parentheses are the actual field computation times, not taking the plot generation into account. 

The main steps, available in the commits are :

1. Initial script in Rust, with plot generation in R, reading the results from a CSV. (~4m w/ 500 break points and 2000x2001)
2. Multithreading (multiprocess) improvement for the Rust script. (~30s w/ 500 break points and 2001x2001)
3. GPU parallelisation using Julia. Why Julia ? Because it has a nice abstraction for CUDA, and because it's quite promising as well. (1s w/ 50 points and 1001x1001, 500 takes too much GPU RAM (>= 6GB))

