# shellcheck shell=bash disable=SC2034
logr INFO "${__include_source_file}"

shopt -s expand_aliases

alias array.getbyref='e="$( declare -p ${1} )"; eval "declare -A E=${e#*=}"'
alias array.foreach='array.keys ${1}; for key in "${KEYS[@]}"'

function array.print {
    array.getbyref
    array.foreach
    do
        echo "[$key]=(${E[$key]})"
    done | sort -rn -k3
}

function array.keys {
    array.getbyref
    KEYS=(${!E[@]})
}

function array.sort () {
	declare -n __unsorted_array="$1"
	declare -n __sorted_array="$2"

	oldIFS="$IFS"; IFS=$'\n'
	if [[ -o noglob ]]
	then
		setglob=1; set -o noglob
	else
		setglob=0
	fi

	__sorted_array=( $(printf '%s\n' "${__unsorted_array[@]}" |
            awk '{ print $NF, $0 }' FS='/' OFS='/' |
            sort | cut -d'/' -f2- ) )

	IFS="$oldIFS"; unset oldIFS
	(( setglob == 1 )) && set +o noglob
	unset setglob
}

function array.to.file()
{

	local __array_name=$1[@]
    local __array=("${!__array_name}")
	local __ARRAY_FILE="$2"
	local __CREATE_NEW="${3:-FALSE}"
	local __EXIT_MSG="${4:-}"


	if [[ $__CREATE_NEW == 1 ]]
	then
		if [[ ! -f $__ARRAY_FILE ]]
		then
			printf "%s\n" "${__array[@]}" > $__ARRAY_FILE

			if [[ $__EXIT_MSG != "" ]]
			then
				echo $__EXIT_MSG
				exit
			fi
		fi
	else

		printf "%s\n" "${__array[@]}" > $__ARRAY_FILE
	fi

	length=$(wc -c <$__ARRAY_FILE)
	if [ "$length" -ne 0 ] && [ -z "$(tail -c -1 <$__ARRAY_FILE)" ]
	then
		# The file ends with a newline or null
		dd if=/dev/null of=$__ARRAY_FILE obs="$((length-1))" seek=1 status=none
	fi
}

function array.search()
{
      local hay needle=$1
      shift

      for hay; do
          [[ $hay == $needle ]] && echo 0 && exit 
      done
      echo 1

}

function array.join { local IFS="$1"; shift; echo "$*"; }

function array.merge() {
    # declare a local **reference variable** (hence `-n`) named `array_reference`
    # which is a reference to the value stored in the first parameter
    # passed in
    local -n map_ref="$1"
    local -n map_ref2="$2"

    # setting the value of keys in the second array, to the value of the same key in the first array
    for key in "${!map_ref2[@]}"; do
        value="${map_ref2["$key"]}"
        #echo "  $key: $value"
        map_ref["$key"]="$value"
    done
}

function array.list()
{
    declare -n array="$1"
    local val=$2


    array+=("${val}")
    
}


function array_diff {
    eval local ARR1=\(\"\${$2[@]}\"\)
    eval local ARR2=\(\"\${$3[@]}\"\)
    local IFS=$'\n'
    mapfile -t $1 < <(comm -23 <(echo "${ARR1[*]}" | sort) <(echo "${ARR2[*]}" | sort))
}