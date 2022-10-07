#!/bin/bash

__INC_LIB_DIR="/home/bjorn/scripts/plextags/include"
# shellcheck source=inc/header.sh
source  "${__INC_LIB_DIR}/header.inc.sh"



declare -A fileArray

gotocontinue="no"
main.search.videos "videoSearchArray" "*.mp4" "" "${__FILELIST}" "${__MAX_RESULTS}"

tLen=${#videoSearchArray[@]}
listRange=$tLen

if [[ -n $__LIST_NUM_FILES ]]
then
  __out=$(string.red $tLen  0 1)
  echo -e "There are $__out files"
  exit
fi


if [[ -n $__IGNORE_NUMBER ]]
then
    ignore_number_array=( $__IGNORE_NUMBER )

    [[ "${__IGNORE_NUMBER}" =~ "," ]] && mapfile  -t -d, -c1 ignore_number_array  <<< "${__IGNORE_NUMBER}"
    if [[ "${__IGNORE_NUMBER}" =~ "-" ]]
    then
        unset ignore_number_array
        __low="${__IGNORE_NUMBER%%-*}"
        __high="${__IGNORE_NUMBER##*-}"
        for i in $(seq $__low $__high)
        do 
            ignore_number_array+=( $i)
        done
    fi

fi

(( __range_low = 0 ))
__start=0

if [[ -n "${__FILE_NUMBER}" ]]
then  
    __range=0
    file_rangeIdx=0

    if [[ "${__FILE_NUMBER}" =~ "-" ]]
    then
        __range_low="${__FILE_NUMBER%%-*}"
        __range_high="${__FILE_NUMBER##*-}"
        __range=1
    fi
    if [[ "${__FILE_NUMBER}" =~ "+" ]]
    then
        __range_low="${__FILE_NUMBER%%+*}"
        __amount="${__FILE_NUMBER##*+}"
        (( __range_high = __range_low + __amount-1 ))

        if  [[ __range_high -gt tLen ]] 
        then
            (( __range_high = tLen  ))
        fi
        __range=1
        
    fi
    
    if [[ "${__range}" == 1 ]]
    then
        if [[ __range_low -gt __range_high ]]
        then
            (( __tmp=__range_low ))
            (( __range_low=__range_high ))
            (( __range_high=__tmp ))
            unset __tmp
        fi 
        

        for i in $(seq  $__range_high -1 $__range_low)
        do 
            file_number_array+=($i)
        done
        (( __start = tLen - __range_high ))
    else
        (( __start = tLen - __FILE_NUMBER ))
        file_number_array+=($__FILE_NUMBER)
    fi
    
    
    file_rangeLen=${#file_number_array[@]}
    listRange=$file_rangeLen
    
fi

(( fileno = tLen - __start ))

for (( q=__start; q < tLen; q++ ))
do

	(( idx = q + 1))
	__skip_progress=0
	if [[ -n "${__FILE_NUMBER}" ]]
	then

        FILE_NUMBER=${file_number_array[$file_rangeIdx]}
        
        if [[ "${FILE_NUMBER}" == "" ]]
        then
            (( q = tLen + 10 ))
            continue
        elif [[ "${FILE_NUMBER}" =~ "${fileno}" ]]
        then         
            (( q = tLen - FILE_NUMBER ))
            (( file_rangeIdx++ ))
        else        
            ((fileno--))
            continue
        fi 
        
	fi
 	currfile=${videoSearchArray[$q]}

    if [[ -n $__IGNORE_NUMBER ]]
    then
        [[ "${ignore_number_array[*]}" =~ "${fileno}" ]] && ((fileno--)) && continue
    fi

	[[ -z $currfile ]] && ((fileno--)) && continue

    file.path "fileArray" "$currfile"
    __cfilename=${fileArray["filename"]}


  #  main.progressBar "$listRange" "$idx" "${fileno}:${__cfilename}"
    main.process fileArray
    ((fileno--))
done
  