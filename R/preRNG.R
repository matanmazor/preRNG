#R version 3.3.2 

library(digest)
library(rngSetSeed)

#Sets the random number generator seed according to the study protocol.
#Params:
#    protocol_folder:    Compressed folder, including all materials to be
#                        preRNGistered.
#    subj_num:           Serial number of current subject.
#Returns:
#    Protocol sum. This should be identical across all subjects.

preRNG <- function(prereg_dir, subj_num = 0){
    
    #Check package installations
    if(!"digest" %in% installed.packages()){
      stop("Please install the \"digest\ package:\n install.packages(\"digest\")")
    }
    if(!"rngSetSeed" %in% installed.packages()){
      stop("Please install the \"rngSetSeed\" package:\n install.packages(\"rngSetSeed\")")
    }
    
    #extract protocol sum
    protocol_sum <- digest(prereg_dir, "sha256", serialize = FALSE, file=TRUE)

    if(subj_num != 0){
        #concatenate subj_number to the end of protocol_sum
        protocol_sum <- paste0(protocol_sum, toString(subj_num))

        #extract sum of the new string 
        subj_sum  <- digest(protocol_sum, "sha256", serialize = FALSE)

    }else{
        subj_sum <- protocol_sum 
    }

    #translate to a vector of numeric values (32 bits each)
    subj_vec <- vector("numeric")
    for (i in 0:(nchar(subj_sum)/8-1)){
      cur_substring <- substr(subj_sum,i*8+1,(i+1)*8)
        subj_vec <- c(subj_vec, as.numeric(paste0("0x", cur_substring)))
    }
    subj_sum <- subj_vec

    #use subj_sum as seed for the pseudorandom number generator
    setVectorSeed(subj_sum)   
   
    return(protocol_sum)
}