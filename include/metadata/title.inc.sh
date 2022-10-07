logr INFO "${__include_source_file}"

# file.get.title
function file.get.title()
{
	local __title

	
	titlestudio=$(filedb.get.studio "title")
	titlestudio_key=${titlestudio//" "/"_"}



main.log "titlestudio_key titlestudio_key " $titlestudio_key
	if [[ -n "${titlestudio_key}" ]]
	then
		if test "${pattern[${titlestudio_key}]+isset}"
		then
		
			[[ $filename =~ ${pattern["$titlestudio_key"]} ]]
			__title=${BASH_REMATCH[2]}
					

			if [[ -n "${__title}" ]]
			then
				if [ "$titlestudio_key" == "Nubiles" ]
				then
					[[ $__title =~ ${pattern["Nubiles_epi"]} ]]
					__orig_title=${BASH_REMATCH[3]}
					__sea=${BASH_REMATCH[1]}
					__epi=${BASH_REMATCH[2]}
					

					if [[ -n "${__epi}" ]]
					then
						__title="${__sea^}:${__epi^} ${__orig_title^}"
					fi

				fi
				if [ "$titlestudio_key" == "Brazzers" ]
				then
					__title=${__title//scene/}
					__title=${__title//-/" "}
				fi
				__title=${__title//-/" "}
				__title=${__title//_/" "}
				if test "${namesPattern[${titlestudio_key}]+isset}"
				then

					__title=$(string.Capitalize "$__title")
				fi
			fi
		fi
	fi
main.log "__title __title " $__title
	# __is_ph=$(pornhub.isFile $filename)
	if [[ -n "${__is_ph}" ]]
	then
		__title=$(pornhub.getValue $filename "title")

	fi

	echo $(string.trim "${__title}")

}


function pornhub.clean.title()
{
	local __text=$1

    __text=${__text//\//-}
	__text=$(string.trans "${__text}")

	for __replacement in "${pornhub_title_filter[@]}"
	do
        __text=${__text/${__replacement}/}
	done

	__text=$(string.trim "${__text}")
	__text=$(string.CapSentance "${__text,,}")

	echo $__text
}


