#!/bin/bash
# 
# Description:
# This script gets all the existing imputations in the root directory and subdirectories
# It's not production ready and only is used for administration purposes
# 
# What should I do?
# * Check wheter notificador directory is located

# output and error message and exit
set -o errexit

# end the script immediately if any command or pipe exits with a non-zero status 
set -o pipefail

# To enable debugging mode remote '#' from the following line 
set -x

# Variables 


_help(){
  cat << EOF
    usage: $1 ARG1
    ARG1 Root directory where the notificador files are stored
    In case ARG1 is empty, the script ends immediately there is no default value

    Description:
    This script manages a testing environment to develop kubernetes developments 
    
    Syntax: k3d.sh [-d|h]

    Example:
      bash k3d.sh -d ../../

    Options:
    h     Print this help 
    d     Directory where notificador files are stored 

    What should it do?
    * Check whether the notificador directory is located 
EOF
}

# Start deployment

_init(){
if [ -n $CI ]; then
    `arkade get $CI;arkade get gitea`
else
    echo "CI not providded choose one of the following [argocd, flux]"
fi
}


# main
while getopts ":hd:" option; do
  case $option in
    h)
    _help
    exit;;
    \?) # Invalid option
    echo "Error: Invalid option"
    exit;;
    d) # Enter the directory
    CI=$OPTARG
    _init
    exit;;
  esac
done
