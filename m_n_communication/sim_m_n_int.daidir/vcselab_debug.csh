#!/bin/csh -f

cd /home/lmjhsxc/eecs470_ia/m_n_communication

#This ENV is used to avoid overriding current script in next vcselab run 
setenv SNPS_VCSELAB_SCRIPT_NO_OVERRIDE  1

/usr/caen/vcs-2022.06/linux64/bin/vcselab $* \
    -o \
    sim_m_n_int \
    -nobanner \
    +vcs+lic+wait \

cd -

