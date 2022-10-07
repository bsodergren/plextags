logr INFO "${__include_source_file}"

function file.move.genre()
{
    local __filename=$1
    local __directory="${2:-$(pwd -P)${__CHANGEDIR}}"
    local __genre
    local genre_array
    local __main_path
    
    __channel_directory="${__directory}"
    
    [[ -d "${__channel_directory}" ]] || mkdir "${__channel_directory}"

    file=$(file.get.path "$__filename" "file")
    filename=$(file.get.path "$__filename" "filename")
    fullpath=$(file.get.path "$__filename" "fullpath")
    filepath=$(file.get.path "$__filename" "filepath")


    __studio_value=$(metadata.get.value "studio")
    if [[ ${__studio_value,,} == "unknown" ]]
    then
        __studio_value="Sort"
        #if [[ -z "${__DEBUG}" ]]
        #then
        #	__options=$(tags.create.optionArg "album" ${__studio_value})
        #	__ret=$(metadata.write ${file} ${__options})
        #fi

    elif [[ ! -n ${__studio_value} ]]
    then

        [[ $filepath =~ $studio_regex ]] # $pat must be unquoted
        __studio_value="${BASH_REMATCH[1]}"
        #if [[ -z "${__DEBUG}" ]]
        #then
        #	__options=$(tags.create.optionArg "album" ${__studio_value})
        #	__ret=$(metadata.write ${file} ${__options})
        #fi

        #__studio_value="Missing"

    fi

    __genre=$(metadata.get.value "genre")

    mapfile  -t -d, -c1 genre_array <<< "${__genre}"
    genre_array=($(printf '%s\n' "${genre_array[@]}" | sort ))

    __main_path="Channels/$__studio_value/"

    __idx=${#genre_array[@]}


    if [[ __idx -gt 0 ]]
    then
        for genre in ${genre_array[@]}
        do

            if [[ $genre == "Amateur" ]]
            then
                __main_path="Amateur/$__studio_value/"
                if [[ __idx -gt 1 ]]
                then
                    continue
                fi

            elif [[ $__main_path == "" ]]
            then
            _   _main_path="/"
            fi

            case ${genre,,} in
                "mff") __main_path="${__main_path}${genre^^}/"
                    break;;
                "mmf") __main_path="${__main_path}${genre^^}/"
                    break;;
                "orgy") __main_path="${__main_path}${genre^}/"
                    break;;
                "group") __main_path="${__main_path}${genre^}/"
                    break;;
                "threesome") __main_path="${__main_path}${genre^}/"
                    break;;
                "compilation") __main_path="${__main_path}${genre^}/"
                    break;;
                "single") __main_path="${__main_path}${genre^}/"
                    break;;
                #*) __main_path="${__main_path}Sort/"
            esac
        done
    else
        __main_path="${__main_path}Sort/"
    fi

    __new_file_dir="${__channel_directory}${__main_path}"
    __new_filename="${__new_file_dir}${filename}"

    if [[ $file != ${__new_filename} ]]
    then
        if [[ -e  ${__new_filename} ]]
        then
            __dup_filename="${filename%.*}.$RANDOM.${filename##*.}"
            __new_file_dir="${__new_file_dir}dupe/"
            __new_filename="${__new_file_dir}${__dup_filename}"
        fi
        if [[ -z "${__DEBUG}" ]]
        then

            [[ -d "${__new_file_dir}" ]] || mkdir -p "${__new_file_dir}"
            #mv "$file" "${__new_filename}"
          
        fi
          __move_files_array+=("${file}|${__new_filename}")
        echo -e "Moving $file -> ${__new_filename}"
    fi
}



# file.get.genre
function file.get.genre()
{
	local __genre
	local __skipph=$1
	local __ph_genre
	local last
    local __tagValues

	shopt -s nocasematch

	[[ $fullpath =~ $genre_regex ]] # $pat must be unquoted
	__genre="${BASH_REMATCH[1]}"
#	__genre=$(string.get.genre $__genre)
	if [[ -n $__skipph ]]
	then
		if [[ "$__genre" != "$fullpath" ]]
		then
			if [[ -n "${__genre}" ]]
			then
				__genre=$(string.trim "${__genre}")

			fi
		fi
	else

		if [[ -n "${__is_ph}" ]]
		then
			__ph_genre=$(pornhub.getValue $filename "genre")

		fi
	fi


    __genre="${__genre},${__ph_genre}"
    __genre=${__genre//\//,}
    __genre=${__genre%*,}
    __genre=${__genre#,*}  
    
    mapfile  -t -d, -c1 genre_array <<< "${__genre}"
    uniq=( $(printf '%s\n' "${genre_array[@]^}" | sort -u) )
    __tagValues=$(IFS=$',';  echo "${uniq[*]}" )

    if [[ "${__tagValues}" == *"Threesome"* ]]
        then
            if [[ "${__tagValues}" == *"MMF"* || "${__tagValues}" == *"MFF"* || "${__tagValues}" == *"Group"* ]]
            then
                __tagValues="${__tagValues//Threesome/}"
                __tagValues="${__tagValues//,,/,}"
            fi
        fi

        if [[ "${__tagValues}" == *"Group"* ]]
        then
            if [[ "${__tagValues}" == *"MMF"* || "${__tagValues}" == *"MFF"*  ]]
            then
                __tagValues="${__tagValues//Group/}"
                __tagValues="${__tagValues//,,/,}"
            fi
        fi
    
    echo $(string.trim "${__tagValues}")

}

function pornhub.clean.genre()
{
	local __value=$1
	local genre_array
	local __genre
	local __out
	local last
	declare -a __genre_array


    if [[ -n "${__value}" ]]
	then
		if [[ "${__value}" =~ "," ]]
		then
			last=${__value#"${__value%?}"}
			while [ ${last} == "," ]
			do
				last=${__value#"${__value%?}"}
				[[ ${last} == "," ]] && __value=${__value::${#__value}-1}
			done
			mapfile  -t -d, -c1 genre_array <<< "${__value}"
		else
			genre_array=("$__value")
		fi


        uniq=( $(printf '%s\n' "${genre_array[@]^}" | sort -u) )
		__out=$(IFS=$',';  echo "${uniq[*]}" )
        mapfile  -t -d, -c1 genre_array <<< "${__out}"
       



		for __genre in "${genre_array[@]}"
		do
            
            __genre_string=$(string.get.genre $__genre)
			__genre_array+=($__genre_string)
		done


	fi

#	if [[ $filepath != "" ]]
        #then
#		__genre_dir=$(basename $filepath)
#		__genre_dir2=${__genre_dir,,}

#		case "${__GENRE_LIST[@]}" in

#			*"$__genre_dir2"*)

#				case "$__genre_dir" in
#					"comp") __genre_dir="compilation";;
#					"only blowjobs") __genre_dir="blowjobs";;
#				esac
#				__genre_array+=(${__genre_dir})
#				;;
#		esac
#	fi


		uniq=( $(printf '%s\n' "${__genre_array[@]^}" | sort -u) )
		__out=$(IFS=$',';  echo "${uniq[*]}" )



	echo "${__out}"
}


function string.get.genre()
{

	local __genre=$1
	local __out
	local __t_genre
	local __genre_key

    
    if [[ $__genre != "" ]]
    then
    
        __genre_key=$( string.clean $__genre)
        __genre_key=${__genre_key//" "/"_"}
        __genre_key=${__genre_key,,}
        __genre_key=${__genre_key//+/}
        __genre_key=${__genre_key//\//_}

        if test "${__genre_list_array[${__genre_key}]+isset}"
        then

            if [[ ${__genre_list_array[${__genre_key}]} != "1" ]]
            then
                __out=${__genre_list_array[${__genre_key}]}
                
            fi
        fi 

        
    fi 
    
    echo ${__out}

}


