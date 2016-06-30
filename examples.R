## 
## Testing example of effcomp
##
##
## 06/29/2016
## Simo Goshev
##
##
##

library(effects)
rm(list=ls())

# source the effcomp.R
source("effcomp.R")


##############################################################################################
### PART 1. ILLUSTRATION OF COMPUTATION

## Making the data easier to work with

Prestige$educ <- round(Prestige$education)
Prestige$educ <- ifelse(Prestige$educ <= 12, 12, Prestige$educ)
Prestige$educ <- ifelse(Prestige$educ >= 14, 14, Prestige$educ)
Prestige$educ <- as.factor(Prestige$educ)

Prestige$income <- Prestige$income/1000

##### ~~~~~~ {TEST 1: ONE VARIABLE} ~~~~~~

##### ~~~~~~ {TEST 1.1: ALL CONTRASTS} ~~~~~~

fit_lm <- lm(prestige ~ income + type + educ, data = Prestige)
type_eff <- effect("type", fit_lm)       # compute effects
as.data.frame(type_eff)                  # print effects

comps <- effcomp(type_eff, all = TRUE)   # compute all contrasts
summary(comps)                           # print contrasts

comps_tests <- testpwcomp(comps)  # compute statistical tests, no adjustment for mulitple comparisons
summary(comps_tests)              # print results

comps_tests_bon <- testpwcomp(comps, "bonferroni")  # compute stat tests, Bonferrroni adj for mult comps
summary(comps_tests_bon)                            # print results

comps_tests_sch <- testpwcomp(comps, "scheffe")  # compute stat tests, Scheffe adj for mult comps
summary(comps_tests_sch)                       # print results


##### ~~~~~~ {TEST 1.2: MATRIX OF LINEAR CONTRASTS} ~~~~~~

contr_mat <- matrix(c(-1, 1, 0,
                      -1, 0, 1),
                    nrow = 2, byrow = TRUE)

comps <- effcomp(type_eff,contr_mat)   # compute all contrasts
summary(comps)                         # print contrasts

comps_tests <- testpwcomp(comps)  # compute statistical tests, no adjustment for mulitple comparisons
summary(comps_tests)          # print results

comps_tests_bon <- testpwcomp(comps, "bonferroni")  # compute stat tests, Bonferrroni adj for mult comps
summary(comps_tests_bon)                   # print results

comps_tests_sch <- testpwcomp(comps, "scheffe")  # compute stat tests, Scheffe adj for mult comps
summary(comps_tests_sch)                   # print results




##### ~~~~~~ {TEST 2: TWO AND MORE VARIABLES} ~~~~~~

##### ~~~~~~ {TEST 2.1: ALL CONTRASTS} ~~~~~~

type_educ <- Effect(c("type","educ"), fit_lm)       # compute effects
as.data.frame(type_educ)                            # print effects

comps <- effcomp(type_educ, all = TRUE)   # compute all contrasts
summary(comps)                          # print contrasts

comps_tests <- testpwcomp(comps)        # compute statistical tests, no adjustment for mulitple comparisons
summary(comps_tests)                    # print results

comps_tests_bon <- testpwcomp(comps, "bonferroni")  # compute stat tests, Bonferrroni adj for mult comps
summary(comps_tests_bon)                           # print results

comps_tests_sch <- testpwcomp(comps, "scheffe")  # compute stat tests, Scheffe adj for mult comps
summary(comps_tests_sch)                         # print results


##### ~~~~~~ {TEST 2.2: MATRIX OF LINEAR CONTRASTS} ~~~~~~

contr_mat <- matrix(c(-1, 1, 0, 0, 0, 0, 0, 0, 0,
                       0,-1, 0, 0, 0, 0, 0, 1, 0,
                       0, 0,-1, 0, 0, 1, 0, 0, 0),
                    nrow = 3, byrow = TRUE)

comps <- effcomp(type_educ,contr_mat)   # compute all contrasts
summary(comps)                          # print contrasts

comps_tests <- testpwcomp(comps)  # compute statistical tests, no adjustment for mulitple comparisons
summary(comps_tests)                   # print results

comps_tests_bon <- testpwcomp(comps, "bonferroni")  # compute stat tests, Bonferrroni adj for mult comps
summary(comps_tests_bon)                   # print results

comps_tests_sch <- testpwcomp(comps, "scheffe")  # compute stat tests, Scheffe adj for mult comps
summary(comps_tests_sch)                        # print results



##### ~~~~~~ {TEST 2.3: THREE (AND MORE) VARIABLES} ~~~~~~

type_educ_inc <- Effect(c("type","educ","income"), fit_lm, xlevels=list(income=c(10,20))) # compute effects
as.data.frame(type_educ_inc)                            # print effects

comps <- effcomp(type_educ_inc, all = TRUE)   # compute all contrasts
summary(comps)                          # print contrasts

comps_tests <- testpwcomp(comps)           # compute statistical tests, no adjustment for mulitple comparisons
summary(comps_tests)                    # print results

comps_tests_bon <- testpwcomp(comps, "bonferroni")  # compute stat tests, Bonferrroni adj for mult comps
summary(comps_tests_bon)                   # print results

comps_tests_sch <- testpwcomp(comps, "scheffe")  # compute stat tests, Scheffe adj for mult comps
summary(comps_tests_sch)                        # print results



##### ~~~~~~ {TEST 2.4: MATRIX OF LINEAR CONTRASTS} ~~~~~~

contr_mat <- matrix(c(-1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                       0,-1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0,
                       0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,-1, 0, 0, 1, 0, 0, 0),
                    nrow = 3, byrow = TRUE)

comps <- effcomp(type_educ_inc, contr_mat)   # compute all contrasts
summary(comps)                         # print contrasts

comps_tests <- testpwcomp(comps)  # compute statistical tests, no adjustment for mulitple comparisons
summary(comps_tests)                   # print results

comps_tests_bon <- testpwcomp(comps, "bonferroni")  # compute stat tests, Bonferrroni adj for mult comps
summary(comps_tests_bon)                            # print results

comps_tests_sch <- testpwcomp(comps, "scheffe")  # compute stat tests, Scheffe adj for mult comps
summary(comps_tests_sch)                         # print results




