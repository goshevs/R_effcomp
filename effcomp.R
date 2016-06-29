##
## Contrasts after effect (effects package)
##
## 06/29/2016
## Simo Goshev
##
##
##

##############################################################################################
### 1. FUNCTION DEFINITION

### R1: ROUTINE FOR COMPUTING PAIR-WISE LINEAR CONTRASTS
effcomp <- function(effects_obj, lincon, all = FALSE) {

    
    nvars <- dim(effects_obj$x)[2]      # get the number of variables used in effects
    df <- c(rep(NA,2))                  # vector to collect degrees of freedom for scheffe
    
    ## Retrieve/create the levels for the pair-wise comparisons
    if (nvars == 1) {
        eff_levs <- as.character(effects_obj$x[[1]]) # get string labels
    }
    else {
        eff_levs <- apply(effects_obj$x, 1, paste, collapse = "-") # merge labels
    }

    ## Check if effects with NA fits exist; remove if present
    index_na <- which(is.na(effects_obj$fit))
    is_na    <- length(index_na)
    
    if (is_na > 0) {
        eff_levs <- eff_levs[-index_na] # filter NA's
        ## Retrieve estimates and variance-covariance matrix and filter NA's
        myvcovs <-  vcov(effects_obj)[-index_na, -index_na]
        mybetas <- effects_obj$fit[-index_na]
    }
    else {
        eff_levs <- eff_levs
        ## Retrieve estimates and variance-covariance matrix
        myvcovs <-  vcov(effects_obj)
        mybetas <- effects_obj$fit
    }

    ## If all possible pair-wise comparisons are needed
    if (all) {
        eff_levs_num <- as.numeric(ordered(eff_levs, levels=c(eff_levs))) # get underlying numbers
        mypairs <- t(combn(eff_levs_num, 2))
        mymatgen <- function(x, mycol){
            mymat <- matrix(c(rep(0, mycol)), nrow = 1)
            mymat[1, x[1]] <- -1
            mymat[1, x[2]] <- 1
            return(mymat)
        }
        ## Create the matrix of linear contrasts
        lincon <- t(apply(mypairs, 1, mymatgen, mycol = length(eff_levs)))
        ## Create the vector of contrast names
        myrow_names <- apply(mypairs, 1, function(x) paste(eff_levs[x[2]], "vs", eff_levs[x[1]]))
                                        # paste("(", x[2], " vs ", x[1], ")", sep=""),

        df[1] <-  dim(effects_obj$x)[1] - 1       # nominator degrees of freedom for scheffe
        
    }
    ## Test for presence of all arguments needed
    else if (all == FALSE & missing(lincon)) {
        stop("Unless using argument all = TRUE, must provide a matrix of linear contrasts")
    }
    
    ## If feeding a matrix of linear contrasts
    else {
        
        ## Remove the columns in lincon which have NA effect fits
        lincon <- if (is_na > 0) lincon[, -index_na] else lincon

        ## Check for correctly specified lincon matrix
        ## Values test
        if (length(which(!(lincon %in% c(0,-1,1)))) == 0) TRUE
        else stop("Contrasts are not defined correctly -- numbers other than 0, -1 and 1 used.")

        ## Row sum test
        if (sum(rowSums(lincon)) == 0) TRUE
        else stop(paste("The matrix of constrasts contains rows that do not sum to zero.\n",
                        "Do not use effects with NA values in constructing contrasts.", sep="  "))
        
        ## Nominator degrees of freedom for scheffe adjustment
        df[1] <- nrow(lincon) 
            
        ### Define a function for apply
        mycontr_fun <- function(x){
            mylevs <- which(x!=0)        # pair we care about
            myx1 <- which(x > 0)         # first element of the pair (e.g. x1 - x2)
            myx2 <- mylevs[which(myx1!=mylevs)]
            myrow_names <- paste(eff_levs[myx1], "vs", eff_levs[myx2])
                                        #paste("(",myx1," vs ",myx2,")", sep=""),
            return(myrow_names)
        }

        ## Pick out the correct rownames from the contrast matrix
        myrow_names <- apply(lincon, 1, mycontr_fun) # this provides for multiple rows in the lincon matrix
    }

    ## Compute the pair-wise linear contrasts
    beta_contr  <- crossprod(t(lincon), mybetas)
    myres <- beta_contr
    rownames(myres) <- myrow_names

    ## Compute the vcov and se's
    vcov_contr <- crossprod(t(crossprod(t(lincon), myvcovs)),t(lincon))
    se_contr   <- as.matrix(sqrt(diag(vcov_contr)))
    
    ## Combine results
    myres <- cbind(myres, se_contr)
    colnames(myres) <- c("Contrast", "SE")

    ## Get sample size and degrees of freedom
    ssize <- dim(effects_obj$data)[1]
    df[2] <- ssize - dim(effects_obj$model.matrix)[2]     # denominator degrees of freedom for scheffe

    ## Number of comparisons (for p-value adjustment)
    ncomp <- length(beta_contr)
    
    ## Return estimates
    list(res = myres, contr = beta_contr, vcov = vcov_contr, ssize = ssize,
         df = df, ncomp = ncomp, labels = myrow_names, mat_lincon = lincon)
}


### R2: ROUTINE FOR COMPUTING STATISTICAL TESTS FOR PAIR-WISE LINEAR CONTRASTS
testpwcomp <- function(effcomp_obj, adjmethod = "none") {

    tval <- effcomp_obj$contr/sqrt(diag(effcomp_obj$vcov))
    pval <- 2*(1 - pt(abs(tval), effcomp_obj$df[2]))

    myres <- cbind(effcomp_obj$res, tval, pval)
    colnames(myres)<- c(colnames(effcomp_obj$res),"t value", "Pr(>|t|)")
      
    if (adjmethod != "none" & length(tval) > 1) {
        ## Note: if only one pwise comparison, no adjustment is needed!
        pval_adj <- p_adjust(pval, adjmethod, effcomp_obj$ncomp, tval = tval, df = effcomp_obj$df)
        
        myres <- cbind(myres, pval_adj)
        colnames(myres)[length(colnames(myres))]<- "AdjPr(>|t|)"
        myout <- list(res = myres, tval = tval, pval_unadj = pval, pval_adj = pval_adj) 
    }
    else {
        myout <- list(res = myres, tval = tval, pval_unadj = pval)
    }
    return(myout)
}


### R3: ROUTINE FOR COMPUTING P-VALUE ADJUSTMENT
p_adjust <- function(pval, adjmethod, n = length(pval), tval = NULL, df = NULL) {

    if (adjmethod %in% c("sidak", "scheffe")) {
        if (adjmethod == "sidak") {
            ## Sidak
            pval_adj <- 1 - (1 - pval)^n
        }
        else {
            ## Scheffe
            pval_adj <- (1 - pf((tval^2)/df[1], df[1], df[2]))
        }
    }
    else {
        ## R built-ins
        ## See p.adjust for allowed methods of adjustment
        pval_adj <- p.adjust(pval, adjmethod)
    }
}

