import random, hashlib, os

def preRNG(protocol_folder, subj_num = 0, save_seeds = 0):
    """
    Sets the random number generator seed according to the study protocol.

    Params:
        protocol_folder:    Compressed folder, including all materials to be
                            preRNGistered.
        subj_num:           Serial number of current subject.
        save_seeds:         If specified, save a csv file with subj_num
                            subject sums.

    Returns:
        Protocol sum. This should be identical across all subjects.

    Raises:
        IOError:            When protocol folder is not found

    >>> import os, shutil
    >>> os.mkdir("protocol")
    >>> protocol_folder = shutil.make_archive("protocol","zip","protocol")
    >>> first_protocol_sum = preRNG(protocol_folder)
    >>> first_int = random.randint(0,1000)
    >>> first_int
    319
    >>> os.rename("protocol.zip","protocol1.zip")
    >>> second_protocol_sum = preRNG("protocol1.zip")
    >>> second_int = random.randint(0,1000)
    >>> first_int == second_int
    True
    >>> first_protocol_sum == second_protocol_sum
    True
    >>> f = open(os.path.join("protocol", "plan"), "w")
    >>> f.close()
    >>> protocol_folder = shutil.make_archive("protocol","zip","protocol")
    >>> third_protocol_sum = preRNG(protocol_folder)
    >>> third_int = random.randint(0,1000)
    >>> first_int == third_int
    False
    >>> first_protocol_sum == third_protocol_sum
    False
    >>> os.remove("protocol.zip")
    >>> os.remove("protocol1.zip")
    >>> shutil.rmtree("protocol") 
    """

    #if protocol folder does not exist, raise an exception
    if not os.path.isfile(protocol_folder):
        raise IOError("protocol_folder not found")
    
    #extract protocol sum
    protocol_sum = hashlib.sha256(open(protocol_folder, 'rb').read()).hexdigest()

    if subj_num != 0:
        #concatenate subj_number to the end of protocol_sum
        concatenated_sum = protocol_sum + str(subj_num);

        #extract sum of the new string 
        subj_sum = hashlib.sha256(concatenated_sum).hexdigest();

    else:
        subj_sum = protocol_sum

    #translate to a number
    subj_sum = int(subj_sum,16);

    #use subj_sum as seed for the pseudorandom number generator
    random.seed(subj_sum)
    
    
    #if save_seeds, iterate over 1:subj_num and create a csv file with the
    #subject sums.
    if save_seeds != 0:
        
        seeds = []
        
        for s in range(1,subj_num+1):
            s_sum = hashlib.sha256(protocol_sum + str(s)).hexdigest();
            s_sum = int(s_sum,16)
            seeds.append(','.join([str(s),str(s_sum)]))
        
        seeds_str = "\n".join(seeds)
        #save the seeds.csv file next to the protocol folder
        fid = open(os.path.join(os.path.dirname(protocol_folder),"seeds.csv"),"w")
        fid.write(seeds_str)
        fid.close()
        
    return protocol_sum

if __name__ == "__main__":
    import doctest
    doctest.testmod()
