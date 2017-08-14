Introduction
============

Package 'effects' in R offers excellent functionality for computing the
type of marginal effects known as average partial effects. An
unfortunate shotfall of the package is that it does not offer
capabilities for computing and testing of pairwise differences in the
margins. The goal of this project is to fill this void.

Installation
============

Download and source *effcomp.R* into R.

Functionality
=============

File *effcomp.R* contains one primary function and several utility
functions. Users would want to use only the primary function.

Primary function
----------------

The primary function is `effcomp`.

`effcomp` computes pairwise differences in margins and also reports
significance tests of differences in the margins, if requested. Its
syntax is:

    effcomp(effects_obj, lincon, all = FALSE, tests = FALSE, ...)

and its arguments are:

-   `effects_obj`: the object created by running either `effect` or
    `Effect` from Package 'effects'

-   `lincon`: stands for "linear contrasts" and is a matrix of pairwise
    linear contrasts which is provided by the user. This argument can be
    omitted if `all = TRUE`

-   `all`: a logical flag which indicates whether all possible pairwise
    contrasts are to be computed. At its default value `FALSE`, the user
    has to provide a matrix of pairwise linear contrasts.

-   `tests`: a logical flag which indicates whether tests of
    significance of the differences in margins are to be computed. By
    default `tests = FALSE`

-   `...`: if `tests = TRUE`, the user may wish pass specify a method
    for adjusting the p-values of the tests for multiple comparisons.
    This is done using the argument `adjmethod` which takes all methods
    described in `p.adjust` of base R as well as `"sidak"` and
    `"scheffe"`. For no adjustment, use `"none"`. The default method is
    `"bonferroni"`.

Utility functions
-----------------

Function `testpwcomp` computes the significance tests, `p_adjust`
computes the p-values adjusted for multiple comparisons.

Examples of usage
=================

We start by removing all objects in memory and loading the effect
package.

    ## Clear memory and load package effects
    rm(list=ls())
    library(effects)

Next, we source *effcomp.R*

    # Source in effcomp.R
    source("effcomp.R")

Finally, we load an example dataset provided in the *effects* package
and make some minor changes to the variables

    ## Making minor changes to the data
    Prestige$educ <- round(Prestige$education)
    Prestige$educ <- ifelse(Prestige$educ <= 12, 12, Prestige$educ)
    Prestige$educ <- ifelse(Prestige$educ >= 14, 14, Prestige$educ)
    Prestige$educ <- as.factor(Prestige$educ)

    Prestige$income <- Prestige$income/1000

We are now ready to illustrate the usage of `effcomp`.

Contrasts of margins, one variable
----------------------------------

We run our model and compute the margins of variable *type*.

    fit_lm <- lm(prestige ~ income + type + educ, data = Prestige)
    type_eff <- effect("type", fit_lm)       # compute effects
    as.data.frame(type_eff)                  # print effects

    ##   type      fit       se    lower    upper
    ## 1   bc 40.23627 1.450572 37.35531 43.11723
    ## 2 prof 58.14816 2.258361 53.66286 62.63346
    ## 3   wc 46.30919 1.811231 42.71193 49.90645

To obtain all possible contrast of the margins of variable *`type`*, we
execute

    comps <- effcomp(type_eff, all = TRUE)   # compute all contrasts
    summary(comps)

    ## 
    ## Call:
    ## effcomp(effects_obj = type_eff, all = TRUE)
    ## 
    ## Pairwise differences of margins.
    ## 
    ## Output:
    ##             Contrast      SE
    ## prof vs bc   17.9119  3.1957
    ## wc vs bc      6.0729  2.0338
    ## wc vs prof  -11.8390  3.3361

If we also want to test whether the margins are different from each
other, we run

    comps <- effcomp(type_eff, all = TRUE, tests = TRUE)   # Bonferroni adjustment, default
    summary(comps)

    ## 
    ## Call:
    ## effcomp(effects_obj = type_eff, all = TRUE, tests = TRUE)
    ## 
    ## Pairwise differences of margins.
    ## 
    ## Output:
    ##             Contrast      SE  t value  Pr(>|t|)  AdjPr(>|t|)
    ## prof vs bc   17.9119  3.1957   5.6049    0.0000       0.0000
    ## wc vs bc      6.0729  2.0338   2.9860    0.0036       0.0109
    ## wc vs prof  -11.8390  3.3361  -3.5487    0.0006       0.0018

In case we want to use a different adjustment, for example Scheffe's, we
specify the command in the following way:

    ## Scheffe adjustment
    comps <- effcomp(type_eff, all = TRUE, tests = TRUE, adjmethod ="scheffe") 
    summary(comps)

    ## 
    ## Call:
    ## effcomp(effects_obj = type_eff, all = TRUE, tests = TRUE, adjmethod = "scheffe")
    ## 
    ## Pairwise differences of margins.
    ## 
    ## Output:
    ##             Contrast      SE  t value  Pr(>|t|)  AdjPr(>|t|)
    ## prof vs bc   17.9119  3.1957   5.6049    0.0000       0.0000
    ## wc vs bc      6.0729  2.0338   2.9860    0.0036       0.0142
    ## wc vs prof  -11.8390  3.3361  -3.5487    0.0006       0.0027

All standard methods for adjustment are available. Sidak's method has
also be added.

`effcomp` also accepts a user provided matrix for constructing desired
contrasts.

    contr_mat <- matrix(c(-1, 1, 0,
                          -1, 0, 1),
                        nrow = 2, byrow = TRUE)

    comps <- effcomp(type_eff,contr_mat)   # compute contrasts
    summary(comps)

    ## 
    ## Call:
    ## effcomp(effects_obj = type_eff, lincon = contr_mat)
    ## 
    ## Pairwise differences of margins.
    ## 
    ## Output:
    ##             Contrast      SE
    ## prof vs bc   17.9119  3.1957
    ## wc vs bc      6.0729  2.0338

To test the differences in the margins (and apply adjustments for
multiple comparisons), we use the following syntax:

-   No adjustment for multiple comparisons

<!-- -->

    ## No adjustment for multiple comparisons
    comps <- effcomp(type_eff, contr_mat, tests = TRUE, adjmethod = "none") 
    summary(comps)

    ## 
    ## Call:
    ## effcomp(effects_obj = type_eff, lincon = contr_mat, tests = TRUE, 
    ##     adjmethod = "none")
    ## 
    ## Pairwise differences of margins.
    ## 
    ## Output:
    ##             Contrast      SE  t value  Pr(>|t|)
    ## prof vs bc   17.9119  3.1957   5.6049    0.0000
    ## wc vs bc      6.0729  2.0338   2.9860    0.0036

-   Bonferroni adjustment for multiple comparisons

<!-- -->

    ## Bonferroni adjustment
    comps <- effcomp(type_eff, contr_mat, tests = TRUE)                     
    summary(comps)

    ## 
    ## Call:
    ## effcomp(effects_obj = type_eff, lincon = contr_mat, tests = TRUE)
    ## 
    ## Pairwise differences of margins.
    ## 
    ## Output:
    ##             Contrast      SE  t value  Pr(>|t|)  AdjPr(>|t|)
    ## prof vs bc   17.9119  3.1957   5.6049    0.0000       0.0000
    ## wc vs bc      6.0729  2.0338   2.9860    0.0036       0.0072

-   Scheffe adjustment for multiple comparisons

<!-- -->

    ## Scheffe's adjustment
    comps <- effcomp(type_eff, contr_mat, tests = TRUE, adjmethod = "scheffe")
    summary(comps)

    ## 
    ## Call:
    ## effcomp(effects_obj = type_eff, lincon = contr_mat, tests = TRUE, 
    ##     adjmethod = "scheffe")
    ## 
    ## Pairwise differences of margins.
    ## 
    ## Output:
    ##             Contrast      SE  t value  Pr(>|t|)  AdjPr(>|t|)
    ## prof vs bc   17.9119  3.1957   5.6049    0.0000       0.0000
    ## wc vs bc      6.0729  2.0338   2.9860    0.0036       0.0142

Contrasts of margins, two or more variables
-------------------------------------------

`effcomp` can be used to construct contrasts of margins computed over
multiple variables.

Here, we compute margins over *`type`* and *`educ`*:

    type_educ <- Effect(c("type","educ"), fit_lm)       # compute effects
    as.data.frame(type_educ)                            # print effects

    ##   type educ      fit       se    lower    upper
    ## 1   bc   12 37.65509 1.225055 35.22203 40.08816
    ## 2 prof   12 55.56698 2.856968 49.89280 61.24117
    ## 3   wc   12 43.72801 1.721530 40.30890 47.14712
    ## 4   bc   13       NA       NA       NA       NA
    ## 5 prof   13 67.99778 4.297428 59.46272 76.53284
    ## 6   wc   13 56.15881 4.188202 47.84068 64.47694
    ## 7   bc   14       NA       NA       NA       NA
    ## 8 prof   14 64.80480 1.858274 61.11411 68.49549
    ## 9   wc   14       NA       NA       NA       NA

To obtain the contrasts of these margins, we use

    comps <- effcomp(type_educ, all = TRUE)   # compute all contrasts
    summary(comps)

    ## 
    ## Call:
    ## effcomp(effects_obj = type_educ, all = TRUE)
    ## 
    ## Pairwise differences of margins.
    ## 
    ## Output:
    ##                     Contrast      SE
    ## prof-12 vs bc-12     17.9119  3.1957
    ## wc-12 vs bc-12        6.0729  2.0338
    ## prof-13 vs bc-12     30.3427  4.5478
    ## wc-13 vs bc-12       18.5037  4.3448
    ## prof-14 vs bc-12     27.1497  2.3585
    ## wc-12 vs prof-12    -11.8390  3.3361
    ## prof-13 vs prof-12   12.4308  4.2291
    ## wc-13 vs prof-12      0.5918  5.7695
    ## prof-14 vs prof-12    9.2378  3.2140
    ## prof-13 vs wc-12     24.2698  4.9743
    ## wc-13 vs wc-12       12.4308  4.2291
    ## prof-14 vs wc-12     21.0768  2.6803
    ## wc-13 vs prof-13    -11.8390  3.3361
    ## prof-14 vs prof-13   -3.1930  4.5002
    ## prof-14 vs wc-13      8.6460  4.6236

If we need to test for significance of the differences, we run:

-   No adjustment for multiple comparisons

<!-- -->

    ## Compute statistical tests, no adjustment for mulitple comparisons
    comps <- effcomp(type_educ, all = TRUE, tests = TRUE, adjmethod = "none")
    summary(comps)

    ## 
    ## Call:
    ## effcomp(effects_obj = type_educ, all = TRUE, tests = TRUE, adjmethod = "none")
    ## 
    ## Pairwise differences of margins.
    ## 
    ## Output:
    ##                     Contrast      SE  t value  Pr(>|t|)
    ## prof-12 vs bc-12     17.9119  3.1957   5.6049    0.0000
    ## wc-12 vs bc-12        6.0729  2.0338   2.9860    0.0036
    ## prof-13 vs bc-12     30.3427  4.5478   6.6720    0.0000
    ## wc-13 vs bc-12       18.5037  4.3448   4.2588    0.0000
    ## prof-14 vs bc-12     27.1497  2.3585  11.5113    0.0000
    ## wc-12 vs prof-12    -11.8390  3.3361  -3.5487    0.0006
    ## prof-13 vs prof-12   12.4308  4.2291   2.9393    0.0042
    ## wc-13 vs prof-12      0.5918  5.7695   0.1026    0.9185
    ## prof-14 vs prof-12    9.2378  3.2140   2.8743    0.0050
    ## prof-13 vs wc-12     24.2698  4.9743   4.8791    0.0000
    ## wc-13 vs wc-12       12.4308  4.2291   2.9393    0.0042
    ## prof-14 vs wc-12     21.0768  2.6803   7.8635    0.0000
    ## wc-13 vs prof-13    -11.8390  3.3361  -3.5487    0.0006
    ## prof-14 vs prof-13   -3.1930  4.5002  -0.7095    0.4798
    ## prof-14 vs wc-13      8.6460  4.6236   1.8700    0.0647

-   Bonferroni adjustment for multiple comparisons

<!-- -->

    ## Bonferroni adjustment for multimple comparisons
    comps <- effcomp(type_educ, all = TRUE, tests = TRUE)
    summary(comps)

    ## 
    ## Call:
    ## effcomp(effects_obj = type_educ, all = TRUE, tests = TRUE)
    ## 
    ## Pairwise differences of margins.
    ## 
    ## Output:
    ##                     Contrast      SE  t value  Pr(>|t|)  AdjPr(>|t|)
    ## prof-12 vs bc-12     17.9119  3.1957   5.6049    0.0000       0.0000
    ## wc-12 vs bc-12        6.0729  2.0338   2.9860    0.0036       0.0543
    ## prof-13 vs bc-12     30.3427  4.5478   6.6720    0.0000       0.0000
    ## wc-13 vs bc-12       18.5037  4.3448   4.2588    0.0000       0.0007
    ## prof-14 vs bc-12     27.1497  2.3585  11.5113    0.0000       0.0000
    ## wc-12 vs prof-12    -11.8390  3.3361  -3.5487    0.0006       0.0092
    ## prof-13 vs prof-12   12.4308  4.2291   2.9393    0.0042       0.0624
    ## wc-13 vs prof-12      0.5918  5.7695   0.1026    0.9185       1.0000
    ## prof-14 vs prof-12    9.2378  3.2140   2.8743    0.0050       0.0754
    ## prof-13 vs wc-12     24.2698  4.9743   4.8791    0.0000       0.0001
    ## wc-13 vs wc-12       12.4308  4.2291   2.9393    0.0042       0.0624
    ## prof-14 vs wc-12     21.0768  2.6803   7.8635    0.0000       0.0000
    ## wc-13 vs prof-13    -11.8390  3.3361  -3.5487    0.0006       0.0092
    ## prof-14 vs prof-13   -3.1930  4.5002  -0.7095    0.4798       1.0000
    ## prof-14 vs wc-13      8.6460  4.6236   1.8700    0.0647       0.9701

-   Scheffe adjustment for multiple comparisons

<!-- -->

    ## Scheffe's adjustment for multimple comparisons
    comps <- effcomp(type_educ, all = TRUE, tests = TRUE, adjmethod = "scheffe")
    summary(comps)

    ## 
    ## Call:
    ## effcomp(effects_obj = type_educ, all = TRUE, tests = TRUE, adjmethod = "scheffe")
    ## 
    ## Pairwise differences of margins.
    ## 
    ## Output:
    ##                     Contrast      SE  t value  Pr(>|t|)  AdjPr(>|t|)
    ## prof-12 vs bc-12     17.9119  3.1957   5.6049    0.0000       0.0005
    ## wc-12 vs bc-12        6.0729  2.0338   2.9860    0.0036       0.3609
    ## prof-13 vs bc-12     30.3427  4.5478   6.6720    0.0000       0.0000
    ## wc-13 vs bc-12       18.5037  4.3448   4.2588    0.0000       0.0293
    ## prof-14 vs bc-12     27.1497  2.3585  11.5113    0.0000       0.0000
    ## wc-12 vs prof-12    -11.8390  3.3361  -3.5487    0.0006       0.1433
    ## prof-13 vs prof-12   12.4308  4.2291   2.9393    0.0042       0.3842
    ## wc-13 vs prof-12      0.5918  5.7695   0.1026    0.9185       1.0000
    ## prof-14 vs prof-12    9.2378  3.2140   2.8743    0.0050       0.4175
    ## prof-13 vs wc-12     24.2698  4.9743   4.8791    0.0000       0.0052
    ## wc-13 vs wc-12       12.4308  4.2291   2.9393    0.0042       0.3842
    ## prof-14 vs wc-12     21.0768  2.6803   7.8635    0.0000       0.0000
    ## wc-13 vs prof-13    -11.8390  3.3361  -3.5487    0.0006       0.1433
    ## prof-14 vs prof-13   -3.1930  4.5002  -0.7095    0.4798       0.9998
    ## prof-14 vs wc-13      8.6460  4.6236   1.8700    0.0647       0.8959

As before, `effcomp` accepts a matrix of user-specified contrasts. We
first create the matrix of contrasts

    contr_mat <- matrix(c(-1, 1, 0, 0, 0, 0, 0, 0, 0,
                           0,-1, 0, 0, 0, 0, 0, 1, 0,
                           0, 0,-1, 0, 0, 1, 0, 0, 0),
                        nrow = 3, byrow = TRUE)

and then feed it to `effcomp`:

    comps <- effcomp(type_educ, contr_mat)   # compute all contrasts
    summary(comps)

    ## 
    ## Call:
    ## effcomp(effects_obj = type_educ, lincon = contr_mat)
    ## 
    ## Pairwise differences of margins.
    ## 
    ## Output:
    ##                     Contrast      SE
    ## prof-12 vs bc-12     17.9119  3.1957
    ## prof-14 vs prof-12    9.2378  3.2140
    ## wc-13 vs wc-12       12.4308  4.2291

Again, to test the differences (and adjust for multiple comparisons
using Scheffe's method) we run

    comps <- effcomp(type_educ, contr_mat, tests = TRUE, adjmethod = "scheffe")
    summary(comps)

    ## 
    ## Call:
    ## effcomp(effects_obj = type_educ, lincon = contr_mat, tests = TRUE, 
    ##     adjmethod = "scheffe")
    ## 
    ## Pairwise differences of margins.
    ## 
    ## Output:
    ##                     Contrast      SE  t value  Pr(>|t|)  AdjPr(>|t|)
    ## prof-12 vs bc-12     17.9119  3.1957   5.6049    0.0000       0.0000
    ## prof-14 vs prof-12    9.2378  3.2140   2.8743    0.0050       0.0470
    ## wc-13 vs wc-12       12.4308  4.2291   2.9393    0.0042       0.0402
