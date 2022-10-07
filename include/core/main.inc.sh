
logr INFO "${__include_source_file}"

function function_name()
{
	for i in "${FUNCNAME[@]:2}"
    do
        rev=("$i" "${rev[@]}")
    done

	function_name=$(IFS=":"; echo "${rev[*]:1}" )
	function_name=${function_name//source:/}
   # function_name=${function_name//:main.log/}
    function_name=$(string.trimLen $function_name 200)

	echo $function_name
}

function main.log()
{
    
    local __level="INFO"
    local __txt=$1
    local __vars=$2
    local __tabs=""
    local __new_level=$3
    local __func=$(string.green $(function_name) 0 1)
	local __line=$(string.purple ${BASH_LINENO} 0 1)
    
     __old_level=${__loger_level}

    [[ "$__new_level" =~ "up" ]] && __loger_level=$((__old_level+1))
    [[ "$__new_level" =~ "down" ]] && __loger_level=$((__old_level-1))
    [[ "$__new_level" =~ ^[0-9]+$ ]] && __loger_level=$__new_level
        
    [[ -z $__loger_level || $__loger_level -lt 0 ]] && __loger_level=0

    __txt=$(string.yellow "${__txt}" 0 1)
    
	__txt=${__txt//%/}
    
    current=`date +%s`
    runtime=$((current-EXEC_START))
    local runtime=$(string.yellow ${runtime} 0 1)

    if [[ ! -z "${__vars}" ]]
	then
        __vars=" ${__vars//\\/\\\\}"
        __vars=${__vars//%/}
        __vars=$(string.red ${__vars} 0 1)
	fi
   
   [[ $__loger_level == 0 ]] && __tabs="${runtime}::"
   __loop=$__loger_level
   
    while [[ $__loop -ge 1 ]]
    do
        __tabs="${__tabs}\t"
        ((__loop--))
    done
    export __loger_level=${__loger_level}

     logr "$__level" "${__tabs}${__func}:${__line}::${__txt} ${__vars}"

    if [[ -n "${__DEBUG}" ]]
    then
        echo -e "$__func:${__line}::${__txt}\t${__vars}" 1>&2
    fi 
    #fi
    
}


function main.progressBar()
{
	local __max=$1
	local __current=$2
	local __label="$3"
	local __option
	local __width=80
	local __string_len
    

    if [[ ! -n "${__DEBUG}" ]]
    then
        
        printf -v pad '%0.1s' "."{1..40}
        #printf -v pad %40s
        __label=$__label$pad
        __label=${__label:0:20}
        __label="${__label} $__current of $__max"
        __label=$__label$pad
        __label=${__label:0:35}

        #if [[ -n ${__PROGRESSBAR_STYLE} ]]
        #then
        #    __option="${__option} --style=${__PROGRESSBAR_STYLE}"
        #fi

        vramsteg --min 0 --max "$__max" --current "$__current" --width $__width --percentage --label="${__label}" ${__option}
    fi 
}

function main.progressBar.end()
{
	vramsteg --remove;
}

function main.process()
{
	declare -n array=$1
	for i in "${!array[@]}"
	do
	  eval $i=\${array[$i]}
	done

	echo "filename $filename"
	echo "file $file"

	echo "Studio $Studio"
	echo "fullpath $fullpath"

	echo "genre $genre"

	echo "library $library"
	


}

function main.search.videos()
{
	declare -n __searchArray="$1"
	local __search_files="${2:-*.mp4}"
	local __searchDir="${3:-$(pwd -P)${__CHANGEDIR}}"
	local __filelist=$4 #{4:-${__FILELIST}}
	local __max=$5 ##{5:-$__MAX_RESULTS}

	local __results_array=()
	local __tmp_array=()
	local q
	local __file
	local i

	[[ "${__max}" == "" ]] && unset __max
	[[ "${__MAX_DEPTH}" == "" ]] && unset __MAX_DEPTH
	[[ "${__searchDir}" == "" ]] && __searchDir=$(pwd -P)${__CHANGEDIR}

	if [[ -n "${__filelist}" ]]
	then
		if [[ "${__filelist}" =~ "," ]]
		then
			mapfile  -t -d, -c1 __searchArray <<< "${__filelist}"
		else
			__searchArray=("$__filelist")
		fi
	else
		if [[ -n "${__MAX_DEPTH}"  ]]
		then
			mapfile -t __searchArray < <(find "${__searchDir}"  -maxdepth "${__MAX_DEPTH}"  -type f  -iname "${__search_files}" -printf "%p\n" | sort -n )
		else
			mapfile -t __searchArray < <(find "${__searchDir}"  -type f  -iname "${__search_files}"  -printf "%p\n" | sort -r )
		fi
	fi

	if [[ -n "${__max}" ]]
	then


		if [[ "${__max}" =~ ":" ]]
		then

			__start=${__max%%:*}
			__max=${__max##*:}

		else
			__start=0

		fi

		__resultLen=${#__searchArray[@]}
		__searchArray=(${__searchArray[@]:$__start:$__max} ${__searchArray[@]:$(($__max + __resultLen))})
	fi

}