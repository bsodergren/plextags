logr INFO "${__include_source_file}"

# filedb.get.studio
function filedb.get.studio()
{
	local __use_titlestudio=$1

	#file: /home/bjorn/plex/XXX/test/Test Studio/mmf/hardcore-dp-on-the-pool-table-28534-720p_full_mp4.mp4
	#filename: hardcore-dp-on-the-pool-table-28534-720p_full_mp4.mp4
	#filepath: Test Studio/mmf/
	#fullpath: /home/bjorn/plex/XXX/test/Test Studio/mmf/

	local __studio
	local __studiodir
	local __genre
	local __nfo_file
	#local __file

	[[ -z "${filepath}" ]] && filepath=$(file.get.path "$__file" "filepath")
	[[ -z "${fullpath}" ]] && fullpath=$(file.get.path "$__file" "fullpath")


  	[[ $filepath =~ $date_regex ]] # $pat must be unquoted
	__date="${BASH_REMATCH[1]}"
	__studiodir="${filepath/\/${__date}\//\/}"

	[[ $__studiodir =~ $genre_regex ]] # $pat must be unquoted
	__genre="${BASH_REMATCH[1]}"
	__studiodir="${__studiodir/\/${__genre}\//\/}"
    
  
    
    last=${__studiodir#"${__studiodir%?}"}
    [[ ${last} == "/" ]] && __studiodir=${__studiodir::${#__studiodir}-1}
	
	__nfo_file="${__studiodir}/site.info"
   





    [[ $__studiodir =~ $studio_regex ]] # $pat must be unquoted
    __studio="${BASH_REMATCH[1]}"



	if [[ -n "${__use_titlestudio}" ]]
	then

		#[[ $__studio == "Misc" ]] && unset __studio
		[[ $__studio == "Favs" ]] && unset __studio
		[[ $__studio == "Sort" ]] && unset __studio
		#[[ $__studiodir == *"Misc"* ]] && __studiodir=${__studiodir///Misc/}
		[[ $__studiodir == *"Favs"* ]] && __studiodir="${__studiodir///Favs/}"
		[[ $__studiodir == *"Sort"* ]] && __studiodir="${__studiodir///Sort/}"
        [[ $__studiodir == *"Channels"* ]] && __studiodir="${__studiodir///Channels/}"
		[[ $__studiodir == *"Favorites"* ]] && __studiodir="${__studiodir///Favorites/}"
		[[ $__studiodir == *"Favorite" ]] && __studiodir="${__studiodir///Favorite/}"
		[[ $__studiodir == *"Downloaded"* ]] && __studiodir="${__studiodir//Downloaded/}"

		if [[ -f "${__nfo_file}" ]]
		then
			__studio=$(head -n 1 "${__nfo_file}")
		fi
	


    #	[[ ${__studiodir} != ${__studio} ]] && __studiodir="${__studiodir/${__studio}/}"
        [[ $__studiodir =~ $studio_regex ]] # $pat must be unquoted
        __studio="${BASH_REMATCH[1]}"

	fi

	echo "${__studio}"

}

# file.get.studio
function file.get.studio()
{
	local __studio

	__genre=$(file.get.genre 1)


	__studiodir="${fullpath/${__genre}/}"
	__nfo_file="${__studiodir}site.info"
	filepath="${filepath/${__genre}/}"
	__main_nfo_file="${__studiodir}../mainsite.info"



	[[ $filepath =~ $date_regex ]] # $pat must be unquoted
	__date="${BASH_REMATCH[1]}"
	__studiodir="${filepath/\/${__date}\//\/}"
	

    [[ $__studiodir =~ $studio_regex ]] # $pat must be unquoted
    __studio="${BASH_REMATCH[1]}"    
	
    [[ $in_directory == "pornhub" ]] && __studio="${BASH_REMATCH[2]}"
    [[ -z "${__studio}" ]] && __studio="${BASH_REMATCH[1]}"

    #[[ $__studio == "Misc" ]] && unset __studio
    [[ $__studio == "Favs" ]] && unset __studio
    [[ $__studio == "Sort" ]] && unset __studio
    [[ $__studio == *"Favorites"* ]] && unset __studio
    [[ $__studio == *"Channels"* ]] && unset __studio
    [[ $__studio == *"Downloaded"* ]] && unset __studio

    __is_ph=$(pornhub.isFile $filename)

	if [[ -n "${__is_ph}" ]]
	then
		__ph_studio=$(pornhub.getValue $filename "studio")
		if [[ -n "${__studio}" ]]
		then
			__studio="$__studio/${__ph_studio/$__studio/}"

		else
			__studio="$__ph_studio"
		fi
	fi

    last=${__studio#"${__studio%?}"}
    [[ ${last} == "/" ]] && __studio=${__studio::${#__studio}-1}

    if [[ -f "${__main_nfo_file}" ]]
    then
        __nfo_main_studio=$(head -n 1 "${__main_nfo_file}")

        if [[ -n "${__studio}" ]]
        then
            __studio="$__studio/${__nfo_main_studio/$__studio\//}"
        else
            __studio="$__nfo_main_studio"
        fi
    fi

    if [[ -f "${__nfo_file}" ]]
    then
        __nfo_studio=$(head -n 1 "${__nfo_file}")

        if [[ -n "${__studio}" ]]
        then
            __studio="$__studio/${__nfo_studio/$__studio\//}"
        else
            __studio="$__nfo_studio"
        fi

    else

        if [[ -n "${__studio}" ]]
        then
            studio_array="${titlestudio_key,,}"
            studio_array=${studio_array// /_}
            studio_array=${studio_array//\//_}
            studio_array=${studio_array//&/}
            studio_array=${studio_array//-/_}

            if [[ ${studio_array} != "" ]]
            then 
                declare -n studio_array_name="studio_patterns_${studio_array}"
                [[ $filename =~ ${studio_file_regex["$studio_array"]} ]]
                __studio_key_filename="${BASH_REMATCH[1]}"

                __addstudio=${studio_array_name[${__studio_key_filename}]}
            fi 
            if [[ -n "${__addstudio}" ]]
            then

                #__tstudio=$(filedb.get.studio "studio")
				#main.log "adding __tstudio " $__tstudio

                #__studio=${__studio//${__tstudio}/}

                #__studio=${__studio#/*}
                #__studio=${__studio%/*}

                __studio="${__addstudio}/${__studio}"
            fi

			
			 if [[ "${titlestudio_key}" != "" ]]
			then
				[[ $filename =~ ${namesPattern["$titlestudio_key"]} ]]
				if test "${studio_match[${titlestudio_key}]+isset}"
				then
						__in_array=1			

					studio_prefix=${BASH_REMATCH[${studio_match[$titlestudio_key]}]}
					__in_array=$(array.search $studio_prefix "${studio_teamskeet_skip[@]}")
					if [[ $__in_array == 0 ]]
					then
						if test "${studio_teamskeet_replace[${studio_prefix}]+isset}"
						then
							__second_studio=${studio_teamskeet_replace[$studio_prefix]}
						fi 
						
					fi
				fi 
			fi
        fi
    fi

    if [[ $(filedb.is.favorite "$filename") == 1 ]]
    then
        if [[ -n "${__studio}" ]]
        then
            __studio="${__studio}/Favorite"
        else
            __studio="Favorite"
        fi
    fi
	
	[[ -n "${__second_studio}" ]] && __studio="${__studio}/${__second_studio}"
    
    __studio=${__studio//\/\//\/}



    echo $(string.trim "${__studio}")
}


function files.sort.studio() {
    
    
    
   	local __filename=$1
	local __genre
	local genre_array
	local __main_path

	file=$(file.get.path "$__filename" "file")
	filename=$(file.get.path "$__filename" "filename")
	fullpath=$(file.get.path "$__filename" "fullpath")
	filepath=$(file.get.path "$__filename" "filepath")



    __genre=$(metadata.get.value "genre")

    mapfile  -t -d, -c1 genre_array <<< "${__genre}"
    genre_array=($(printf '%s\n' "${genre_array[@]}" | sort ))


  __idx=${#genre_array[@]}


    if [[ __idx -gt 0 ]]
    then
        for genre in ${genre_array[@]}
        do

            case ${genre,,} in
                "mff") __genre_path="${genre^^}/"
                    break;;
                "mmf") __genre_path="${genre^^}/"
                    break;;
                "orgy") __genre_path="Group/"
                    break;;
                "group") __genre_path="Group/"
                    break;;
                "threesome") __genre_path="${genre^}/"
                    break;;
                "compilation") __genre_path="${genre^}/"
                    break;;
                "single") __genre_path="${genre^}/"
                break;;
            esac
        done
    else
    __genre_path=""
    fi




    __Channel_path=""   

	__studio_value=$(metadata.get.value "studio")
    
    __studio_value=$(string.trim $__studio_value)

    __studio_value=${__studio_value//Favorite/}
    __studio_value=${__studio_value%%/*}
    


    if [[  "$__studio_value" != "" && "${__studioArray[@]}" =~ "${__studio_value,,}"  ]]
    then   
        __Channel_path="Channels/"
        __studio_value="${__studio_value}/"
        __path_loc=1
        
    elif [[  "$__studio_value" != "" && "${__AmateurArray[@]}" =~ "${__studio_value,,}"  ]]
    then
        __Channel_path="Amateur/"
        __studio_value="${__studio_value}/"
        __path_loc=2
        
    elif [[  "$__studio_value" != "" 
#        &&  "$__studio_value" != "Unknown" 
#        &&  "$__studio_value" != "Misc"
#        && "$__studio_value" != "Favorite"
#        && "$__studio_value" != "Other"
     ]]
    then
        __Channel_path="Misc/"
        __studio_value="${__studio_value}/"
        __path_loc=4
    else 
        __Channel_path="Sort"
        __studio_value="${__studio_value}/"
        __path_loc=5
    fi
    
    __new_file_path="${directory}${__Channel_path}${__studio_value}${__genre_path}"
    __new_filename="${__new_file_path}${filename}"
    
    if [[ ! -f "${__new_filename}" ]]
    then
        __move_files_array+=("${file}|${__new_filename}")
    else 
#        if [[ -n "${__DEBUG}" ]]
#        then
            echo "${__new_filename} exists in location"
#        fi 
    fi
}


function pornhub.clean.studio()
{
	local __text=$1
    __text=${__text%%/*}

    __studio_key=$(string.clean $__text)
    __studio_key=${__studio_key//" "/"_"}
    __studio_key=${__studio_key,,}
    __studio_key=${__studio_key//+/}
    __studio_key=${__studio_key//\//_}
    
    if [[ $__studio_key != "" ]]
    then 
        if test "${__studio_replacement_array[${__studio_key}]+isset}"
        then
            __text=${__studio_replacement_array[${__studio_key}]}
        fi
     fi
     

	__text=$(string.trim "${__text}")

    echo $__text
}

