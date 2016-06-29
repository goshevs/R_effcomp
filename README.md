# An R Utility for Pairwise Comparisons of Margins Computed with Functions in Package 'effects'


Package 'effects' in R offers excellent functionality for
computing the type of marginal effects known as average partial
effects. An unfortunate shotfall of the package is that it does not
offer capabilities for computing and testing of pair-wise differences
in the margins. The goal of this project is to fill this void.

The repo contains two files: _effcomp.R_ and _examples.R_. The content
of each file is discussed in more detail below.

## File effcomp.R

File _effcomp.R_ contains three functions: two primary functions and one
utility function. Users of the package would perhaps want to
consider using only the primary functions.

### Primary functions

The primary functions are `effcomp` and `testpwcomp`. 

Function `effcomp` computes pair-wise differences in margins. Its
syntax is:  

    effcomp(effects_obj, lincon, all = FALSE)

and its arguments are:

+ `effects_obj`: the object created by running either `effect` or
  `Effect` from Package 'effects'
  
+ `lincon`: stands for "linear contrasts" and is a matrix of
  pair-wise linear contrasts which is provided by the user. This
  argument can be omitted if `all == TRUE`
  
+ `all`: a logical flag which indicates whether all possible
  pair-wise contrasts are to be computed. At its default value
  `FALSE`, the user has to provide a matrix of pair-wise linear
  contrasts.
  
Function `testpwcomp` computes statistical tests for the
pair-wise differences of margins. It also allows for adjustment of the
p-values of the tests for multiple comparisons. The syntax of the
command is:

    testpwcomp(effcomp_obj, adjmethod = "none")
    
and its arguments are:

+ `effcomp_obj`: the object created by running `effcomp`
  
+ `adjmethod`: the method for adjusting the p-values of the
  statistical tests. Default value is `"none"`. Available methods are all
  methods described in `p.adjust` of base R, "sidak" and "scheffe".
  
  
### Utility function

The utility function `p_adjust` computes p-values adjusted for
multiple comparisons. It adds two new p-value adjustement methods to R
base's `p.adjust`, "sidak" and "scheffe", and is called by `testpwcomp()`.


## File examples.R

This file contains examples of the various uses of the functions
provided in _effcomp.R_.

