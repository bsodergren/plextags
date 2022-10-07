# shellcheck shell=bash disable=SC1090

# failsafe - fall back to current directory
[ "$DIR" == "" ] && DIR="."
 
export __THIS_SCRIPT=$(basename "$0")
export __PLEX_HOME="${HOME}/plex/XXX"
export __PLEX_DUPES="${__PLEX_HOME}/dupes"
export __SCRIPT_HOME="${HOME}/scripts/plextags"
export __INC_MOD_DIR="${__SCRIPT_HOME}/module"
export __GENRE_MAP_FILE="${__INC_LIB_DIR}/data/genre.txt"

function options.get()
{
	local __varname=$1

	if test "${OPTION_ARRAY[$__varname]+isset}"
	then
		[[ "${OPTION_ARRAY[$__varname]}" != "" ]] && echo ${OPTION_ARRAY[$__varname]}; return
	fi
}

function options.set()
{
	local __varname=$1
	local __value=$2
	OPTION_ARRAY[$__varname]=$__value
}


source "${__INC_LIB_DIR}/logr.inc.sh"
__logr_LOG_DIR="/home/bjorn/logs"

[[ -z "${__logr_LOG_NAME}" ]] && __logr_LOG_NAME="${__THIS_SCRIPT}"

logr start  "${__logr_LOG_NAME}"
logr clear

mapfile -t __plextag_inc_array < <(find "${__INC_LIB_DIR}"  -mindepth 1 -type d)
dLen=${#__plextag_inc_array[@]}
for ((i = 0; i < dLen; i++))
do
	mapfile -t __inc_core_array < <(find "${__plextag_inc_array[$i]}" -type f -name "*.inc.sh")
	sLen=${#__inc_core_array[@]}
	for ((z = 0; z < sLen; z++))
	do
		__include_source_file="${__inc_core_array[$z]}"
		source "${__include_source_file}"
	done
done

__bash_colors=("black" "red" "green" "yellow" "blue" "purple" "cyan" "light_gray" "dark_gray" "light_red" "light_green" "light_yellow" "light_blue" "light_magenta" "light_cyan" "white")
for __bash_color in ${__bash_colors[@]}
do
	attr $__bash_color
done

__source_script="${__INC_MOD_DIR}/${__THIS_SCRIPT%.*}/header.sh"
[[ -f $__source_script ]] && source "$__source_script"

__getopts_script="${__INC_MOD_DIR}/${__THIS_SCRIPT%.*}/getopts.sh"
if [[ ! -f $__getopts_script ]]
then
    __getopts_script="${__INC_LIB_DIR}/getopts.sh"
fi 

source "$__getopts_script"

logr INFO "params ${params}"

if [[ -n "${__FILELIST}" ]]
then

    mapfile  -t -d, -c1 __currentDirectoryArr <<< "${__FILELIST}"
else
	mapfile  -t -d, -c1 __currentDirectoryArr <<< $(pwd)
fi

__current_directory=$(realpath "${__currentDirectoryArr[0]}")

logr INFO "__current_directory ${__current_directory}"

[[ $__current_directory =~ $directory_regex ]] # $pat must be unquoted
in_dir="${BASH_REMATCH[1]}"
studio_directory="${BASH_REMATCH[2]}"

case "$in_dir" in
#	"Sites") directory="${__PLEX_HOME}/Sites/" ;;
	"Studios") 	    directory="Studios/"
                    in_directory="studio" ;;
                    
	"BiSexual") 	directory="BiSexual/" ;;
	"Test") 	    directory="Test/" ;;
	"Pornhub") 	    directory="Pornhub/"
                    in_directory="pornhub"
                    ;;
                    
    "Videos") 	    directory="Home/Videos/" ;;
	*) 			    directory="";;
esac

export directory="${__PLEX_HOME}/${directory}"
export __INC_DB_DIR="${__SCRIPT_HOME}/data/${in_dir}"

[[ -d "${__INC_DB_DIR}" ]] || mkdir -p "${__INC_DB_DIR}"  

logr INFO "directory ${directory}"
logr INFO "studio_directory ${studio_directory}"

[[ -z "$__TITLE_NFO" ]] && __TITLE_NFO="titledb.csv"
[[ -z "$__SHELL_SCRIPT_FILE" ]] && __SHELL_SCRIPT_FILE="${directory}/runme.sh"
[[ -z "$__FAVORITE_NFO" ]] && __FAVORITE_NFO="${__INC_DB_DIR}/.favorites.hash"
[[ -z "$__METADB_HASH" ]] && __METADB_HASH="${__INC_DB_DIR}/.metadb.hash"
[[ -z "$__FILELIST_TXT" ]] && __FILELIST_TXT="${__INC_DB_DIR}/.filelist.hash"
[[ -z "$__MISSING_FILES" ]] && __MISSING_FILES="${directory}/missing.txt"
[[ -z "$__BROKEN_FILES" ]] && __BROKEN_FILES="${directory}/broken.txt"
[[ -z "$__TEMP_FILE_LIST" ]] && __TEMP_FILE_LIST="/tmp/plexdata/tmp_list.$BASHPID"


file.prepend $__TEMP_FILE_LIST $__TEMP_FILE_LIST

