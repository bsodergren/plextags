# shellcheck shell=bash



function pornhub.filekey()
{
	local __arg_key=$1
	local __key


	if [[ $__arg_key =~ ^[0-9]+$ ]]
	then
		__key=$__arg_key
	else
		regex='.*\_([0-9]*)'
		[[ $__arg_key =~ $regex ]] # $pat must be unquoted
		__key="${BASH_REMATCH[1]}"
	fi

	echo $__key

}


function pornhub.isFile()
{
	local __filename="$1"
	local __is_pornhub=""



	__ph_regex='.*_?[0-9]{3,5}[pP]?\_[0-9\.]{2,6}[kK]?\_([0-9]{3,15})'

	[[ $__filename =~ $__ph_regex ]] # $pat must be unquoted
	__is_pornhub="${BASH_REMATCH[1]}"

	if [[ -n "${__is_pornhub}" ]]
	then
		echo "Pornhub"
	fi
    }

function pornhub.getValue()
{
    local __filename=$1
    local __tag=$2
    local __ph_url
    local __tag_value


    __tag_value=$(pornhub.get.TagValue $__filename "${__tag}")
    
    if [[ ! -n "${__tag_value}" ]]
    then 
        __ph_url=$(pornhub.get.TagValue $__filename "url")



        if [[ ! -n ${__ph_url} ]]
        then
            ## try searching filename instead
            __tag_value=$(pornhub.get.webdata $__filename "${__tag}")
        else
            __tag_value=$(pornhub.get.webdata $__ph_url "${__tag}")
        fi
    fi 

    [[ $__tag_value == "No" && $__tag == "artist" ]] && unset __tag_value
    #[[ $__tag_value == "Unknown" && $__tag == "studio" ]] && __tag_value="Unknown"
    #[[ $__tag_value == "unknown" && $__tag == "studio" ]] && __tag_value="Unknown"

    #unset __tag_value


    [[ $__tag == "genre" ]] && __tag_value=$(pornhub.clean.genre "${__tag_value}")


    __tag_value=${__tag_value//\\\'/\'}
    __tag_value=${__tag_value//\\/}
    __tag_value=${__tag_value//\%/}




    echo "${__tag_value}"
}


function pornhub.get.TagValue()
{
	local __filename=$1
	local __tag=$2
	local __ph_key
	local __return



    __return=$(mysql.get.TagValue $__filename "${__tag}" )
    __return=$(string.trim $__return)

    __return=${__return//;/,}

    [[ ${__return:0:1} == "," ]] && __return=${__return#","}

    __return=${__return//\\'/\'}

    __return=${__return//,,/,}

    
    [[ ${__tag} == "genre" ]] && __return=${__return//-/ }

     
    [[ $__tag == "title" ]] && __return=$(pornhub.clean.title "${__return}")
    [[ $__tag == "studio" ]] && __return=$(pornhub.clean.studio "${__return}")
    
    __return=$(string.clean "${__return}")

	echo $__return

}



function pornhub.get.webdata()
{
	local __full_url=$1
	local __tag=$2
	local __filename=${3:-$filename}
	local __SKIP


	if [[ ${__full_url} =~ "," ]]
	then
    mapfile  -t -d, -c1 __array <<< ${__full_url}
		__full_url=${__array[0]}
		__full_url=${__filename/\"/}
		__full_url=$(string.trim $__full_url)

		__filename=${__array[1]}
		__filename=${__filename/\"/}
		__filename=$(string.trim $__filename)
	fi

	[[ -z ${__filename} ]] && __filename="temp_file.mp4"

	case "$__tag" in
		"studio")
				__dimension_regex="dimension24',.*'(.*)'";;
		"genre")
				__dimension_regex="dimension10',.*'(.*)'";;
		"artist")
				__dimension_regex="dimension9',.*'(.*)'";;
		"title")
				__dimension_regex='.*og:title.*=\"(.*)\".*';;
	esac

	unset __SKIP
	__SILENT=" -s "

	[[ $__tag == "update" ]] && __SKIP="-s"; __SILENT=""
	[[ $__tag == "missing" ]] && __SKIP="-s"; __SILENT=""


	if [[ $__full_url != ${__filename} ]]
	then
		__url=${__full_url//embed\//view_video.php\?viewkey\=}
	fi

	[[ -d "${__CACHE_DIR}/html" ]] || mkdir -p "${__CACHE_DIR}/html"
	__cache_html="${__CACHE_DIR}/html/${__filename}.html"
	__cache_html_gz="${__cache_html}.gz"

	[[ -d "${__CACHE_DIR}/fail" ]] || mkdir -p "${__CACHE_DIR}/fail"
	__cache_fail="${__CACHE_DIR}/fail/${__filename}.txt"

	[[ -d "${__CACHE_DIR}/missing" ]] || mkdir -p "${__CACHE_DIR}/missing"
	__cache_missing="${__CACHE_DIR}/missing/${__filename}.txt"
	__genre_file="${__CACHE_DIR}/genre.list.txt"




	if [[ -n $__url ]]
	then
		__cache_name=${__url##*=}

		[[ -d "${__PH_CACHE_DIR}" ]] || mkdir -p "${__PH_CACHE_DIR}"

		__cache_file="${__PH_CACHE_DIR}/${__cache_name}"
		unset __cache_string
        
        if [[ -n "$__REFRESH" ]]
        then        
			[[ -f $__cache_file ]] 		&& rm $__cache_file
			[[ -f $__cache_missing ]] 	&& rm $__cache_missing
            [[ -f $__cache_html_gz ]] 	&& rm $__cache_html_gz
		fi




		if [[ ! -f $__cache_file ]]
		then

			if [[ ! -f ${__cache_html_gz} ]]
			then
				__ph_tmpfile="$(mktemp /tmp/plexdata/pornhub.XXXXXXXXXX)"

                file.prepend $__TEMP_FILE_LIST $__ph_tmpfile

				#sleep 5
                

				__out=$(wget -qO - "${__url}" -O "${__ph_tmpfile}")
				__error=$?


				if [[ $__error -ne 0 ]]
				then
					__error_text=$(string.error "curl" $__error)


                    #[[ $__tag == "studio" ]] &&  __result="Deleted"
                    
					echo "Filename: ${__filename}" > ${__cache_fail}
					echo "Error Text: ${__error_text}" >> ${__cache_fail}
					echo "URL: ${__url}" >> ${__cache_fail}

				else
					$(gzip -c  ${__ph_tmpfile} > ${__cache_html_gz} )
					[[ -f $__ph_tmpfile ]] && rm $__ph_tmpfile
				fi
			fi
             

            if [[ -f ${__cache_html_gz} ]]
            then
                echo -e "${filepath}${__filename}" > ${__cache_file}
                echo -e "${__cache_html_gz}" >> ${__cache_file}            
                echo -e "URL: ${__url}" >> ${__cache_file}

                __model_hub_title=$(zgrep -i -E "videotitle" ${__cache_html_gz} |perl -n -e '/videotitle:(.*),/gi && printf "%s",$1')
                __model_hub_owner=$(zgrep -i -E "videoowner" ${__cache_html_gz} |perl -n -e '/videoowner\":\"([^\"]*)\"/i && printf "%s",$1')
                
                if [[ -z $__model_hub_owner ]]
                then
                __model_hub_owner=$(zgrep -iE "\"author\"" ${__cache_html_gz}  |perl -n -e '/\"author\".*\"(.*)\",/i && printf "%s", $1')
                fi 

                __model_hub_genre=$(zgrep -i -E 'href=\/categories' ${__cache_html_gz} | perl -n -e '/categories\/.*>(.*)<\/a>/i && printf "%s,", $1')

                if [[ -n $__model_hub_title ]]
                then


                    __model_hub_title=$(string.clean $__model_hub_title)

                    __cache_string_d="<meta property=\"og:title\" content=\"${__model_hub_title}\" />"

            else
                __cache_string_d=$(zgrep -E -m 1 '"videoTitle":.*' ${__cache_html_gz})


            fi

            if [[ -n $__model_hub_owner ]]
            then
                __cache_string_c="ga('set', 'dimension24', '${__model_hub_owner}')"
            else
                __cache_string_c=$(zgrep -E 'dimension24' ${__cache_html_gz})
            fi

            __cache_string_a=$(zgrep -E 'dimension9' ${__cache_html_gz})

			if [[ -n $__model_hub_genre ]]
			then
				__cache_string_b="ga('set', 'dimension10', '${__model_hub_genre}')"
            else
                __cache_string_b=$(zgrep -E 'dimension10' ${__cache_html_gz})
            fi

			[[ -n "${__cache_string_a}" ]] && echo -e "${__cache_string_a}" >> ${__cache_file}

			if [[ -n "${__cache_string_b}" ]]
			then
				echo -e "${__cache_string_b}" >> ${__cache_file}
#					
				g_regex="dimension10',.*'(.*)'"
				[[ $__cache_string_b =~ $g_regex ]] # $pat must be unquoted
				__line="${BASH_REMATCH[1]}"

				mapfile  -t -d, -c1 __b_result_array <<< "${__line}"
				for __result_value in "${__b_result_array[@]}"
				do
					__result_value=$(string.clean "${__result_value}")
					if [[ -n "${__result_value}" ]]
					then
                        genre_exists=$(grep  "${__result_value}" ${__genre_file})
                       if [[ ! "$genre_exists" ]]                      
                        then
                            # code if found
				            echo -e "${__result_value}" >> ${__genre_file}
                         #code if not found
                        fi
						
					fi
				done

			fi
            
			[[ -n "${__cache_string_c}" ]] && echo -e "${__cache_string_c}" >> ${__cache_file}
			[[ -n "${__cache_string_d}" ]] && echo -e "${__cache_string_d}" >> ${__cache_file}

#				if [[ -n "${__VERBOSE}" ]]
#				then
#					echo "Updated $filename"
#				fi

			[[ -f $__cache_fail ]] && rm $__cache_fail

            fi
        fi
        



        if [[ ! -n "${__SKIP}" ]]
        then
            if [[ -f $__cache_file ]]
            then
                while read -r line
                do
                    [[ $line =~ $__dimension_regex ]] # $pat must be unquoted
                    __result="${BASH_REMATCH[1]}"
                    [[ -n $__result ]] && break
                done < "$__cache_file"
                __result=$(echo $__result | perl -MHTML::Entities -pe 'decode_entities($_);')
                __result=$(string.clean "${__result}")

                [[ $__tag == "title" ]] && __result=$(pornhub.clean.title "${__result}")
                [[ $__tag == "studio" ]] && __result=$(pornhub.clean.studio "${__result}")
                
                if [[ $__tag == "genre" ]]
                then
                    mapfile  -t -d, -c1 __result_array <<< "${__result}"
                    for __result_value in "${__result_array[@]}"
                    do
                        __result_value=$(string.clean "${__result_value}")
                        if [[ -n "${__result_value}" ]]
                        then
                            genre_exists=$(grep  "${__result_value}" ${__genre_file})
                           if [[ ! "$genre_exists" ]]                      
                            then
                                # code if found
                                echo -e "${__result_value}" >> ${__genre_file}
                          
                            fi
                        fi
                    done
                fi

            else

                __result=""
            fi
            main.log "Pre __result __result " "${__result}" "up"

            echo "${__result}"
        fi

	fi
}


