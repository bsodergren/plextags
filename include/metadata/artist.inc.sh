logr INFO "${__include_source_file}"


function file.sanitize.artist()
{
	local __value=$1
	local __name=''

	__name=${__value//_/ }

    if [[ $__name != "RayVeness" &&
		$__name != "CherieDeVille" ]]
	then
		__name=$(string.Capitalize "$__name")
	fi

	if [[ $__name == "CherieDeVille" ]]
	then
		__name="Cherie DeVille"
	fi

	if [[ $__name == "Chloé" || $__name == "Chloé Lacourt" ]]
	then
		__name="Chloe Lacourt"
	fi
    
    if test "${purgatory_names[${__name}]+isset}"
		then
        __name=${purgatory_names[$__name]}
    fi
	__name=$(echo "${__name,,}" | sed -e "s/\b\(.\)/\u\1/g")
	__name=$(string.trim "$__name")

	[[ $__name =~ ([a-zA-Z\ ]{1,}) ]]
	__name=${BASH_REMATCH[0]}

	echo ${__name}
}

# file.get.artist
function file.get.artist()
{
	local names_list=""
	local names
	local name


	__genre=$(file.get.genre 1)
	
	if [[ -n "${titlestudio_key}" ]]
	then
		if test "${namesPattern[${titlestudio_key}]+isset}"
		then
			[[ $filename =~ ${namesPattern["$titlestudio_key"]} ]]
           
			if test "${studio_match[${titlestudio_key}]+isset}"
			then
		     studio_prefix=${BASH_REMATCH[${studio_match[$titlestudio_key]}]}
			fi
            
			names=${BASH_REMATCH[${artist_match["$titlestudio_key"]}]}

			if [[ -n $studio_prefix ]]
			then
				__in_array=$(array.search $studio_prefix ${studio_teamskeet_skip[@]})
			else
				__in_array=1
			fi

			if [[ $__in_array == 1 ]]
			then
				if [[ -n "${names}" ]]
				then
					names_list=""
					names=${names// /_}


# (( $__genre == "MMF" ||
# $__genre == "Single" ) &&
# $titlestudio_key == "Brazzers" ) ||
					if [[ 
						 $names == "syren_de_mer" ||
						 $names == "ryan_conner" ]]
					then
						myarray+=("${names//_/ }")
					else
						delimiter=${delimiterChar["$titlestudio_key"]}
						string=$names$delimiter
						myarray=()
						while [[ $string ]]
						do
							myarray+=("${string%%"$delimiter"*}")
							string=${string#*"$delimiter"}
						done
					fi
					#Print the words after the split
					for value in "${myarray[@]}"
					do
						if [[ ! "${__namesArray[@]}" =~ "${value,,}"  ]]
						then
							name=$(file.sanitize.artist ${value})
							names_list="${names_list}${name},"
						elif test "${purgatory_names[${value}]+isset}"
                        then                            
                            names_list="${names_list}${purgatory_names[$value]},"
                        fi 
                            
					done
					IFS=$OLDIFS
					last=${names_list#"${names_list%?}"}
					[[ ${last} == "," ]] && names_list=${names_list::${#names_list}-1}
				fi
		fi
		fi
	fi
	__is_ph=$(pornhub.isFile $filename)
	if [[ -n "${__is_ph}" ]]
	then
		names_list=$(pornhub.getValue $filename "artist")
	fi
	
	echo $(string.trim "${names_list}")
}
