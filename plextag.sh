#!/bin/bash

__INC_LIB_DIR="/home/bjorn/scripts/plextags/include"
# shellcheck source=inc/header.sh
source  "${__INC_LIB_DIR}/header.inc.sh"
gotocontinue="no"
main.search.videos "videoSearchArray" "*.mp4" "" "${__FILELIST}" "${__MAX_RESULTS}"
tLen=${#videoSearchArray[@]}
listRange=$tLen

fileno=$tLen 
for (( q=0; q < tLen; q++ ))
do

  currfile=${videoSearchArray[$q]}
  echo $currfile
  
  #main.progressBar "$listRange" "$q" "${fileno}:${currfile}"
  ((fileno--))
  
  
 done
 