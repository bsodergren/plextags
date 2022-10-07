# shellcheck shell=bash disable=SC2034
logr INFO "${__include_source_file}"

function string.CapSentance()
{
	local __string=$1
		__string=$( echo $__string | sed -e "s/\b./\u\0/g")
		echo $__string
}
# string.Capitalize
function string.Capitalize()
{
	local __string=$1

	local __word
	local __match
	local __replace
	main.log "Strng to cap " $__string
	
	for __word in "${replace_words_array[@]}"
	do
		__match="${__word%%:*}"
		__replace="${__word##*:}"
		__string=$( echo $__string | sed "s/$__match/$__replace/g")

	done
	__string=$( echo $__string | sed 's/\([a-z]\)\([A-Z]\)/\1 \2/g' | sed 's/^ *//;s/ *$//')

	__string=$( echo $__string | sed 's/\(DP\)\([A-Z]\)/\1 \2/g' | sed 's/^ *//;s/ *$//')
	__string=$( echo $__string | sed 's/\([A-Z]\)\(DP\)/\1 \2/g' | sed 's/^ *//;s/ *$//')
	__string=$( echo $__string | sed 's/\(POV\)\([A-Z]\)/\1 \2/g' | sed 's/^ *//;s/ *$//')
	__string=$( echo $__string | sed 's/\([A-Z]\)\(POV\)/\1 \2/g' | sed 's/^ *//;s/ *$//')
	__string=$( echo $__string | sed 's/\(A\)\([A-Z]\)/\1 \2/g' | sed 's/^ *//;s/ *$//')

	#__string=$( echo $__string | sed 's/\(I\)\([A-Z]\)/\1 \2/g' | sed 's/^ *//;s/ *$//')
	__string=$( echo $__string | sed 's/\([A-Za-z]\)\(1st\)/\1 \2/g' | sed 's/^ *//;s/ *$//')
	__string=$( echo $__string | sed 's/\(10\)\([A-Z]\)/ \1 \2/g' | sed 's/^ *//;s/ *$//')
	__string=$( echo $__string | sed 's/\([A-Za-z]\)\(18th\)/\1 \2/g' | sed 's/^ *//;s/ *$//')
	__string=$( echo $__string | sed 's/\(XL\)\([A-Z]\)/ \1 \2/g' | sed 's/^ *//;s/ *$//')
	__string=$( echo $__string | sed 's/\(MI LF\)\(MILF\)/ \1 \2/g' | sed 's/^ *//;s/ *$//')

	#	__string=$( echo $__string | sed 's/\(XL\)\([A-Z]\)/ \1 \2/g' | sed 's/^ *//;s/ *$//')
	__string=${__string/MI LF/MILF}
	__string=${__string/VI P/VIP}
                    main.log "Strng to cap " $__string                       

	echo "${__string}"
}

# string.verbose.out
function string.verbose.out()
{

	local __options=$1
    local __updates=$2
	local __out
    
    string_color="string.green"

    if [[ -n $__updates ]]
    then 
        IFS='|' read -r -a array <<< "$__updates"
        
        
        [[ -n ${array[0]} ]] && genre=$(string.red "\"${array[0]}\"" );genre="Current=${genre}"
        [[ -n ${array[1]} ]] && title=$(string.red "\"${array[1]}\"" );title="Current=${title}"
        [[ -n ${array[2]} ]] &&  album=$(string.red "\"${array[2]}\"" );album="Current=${album}"
        [[ -n ${array[3]} ]] && artist=$(string.red "\"${array[3]}\"");artist="Current=${artist}" 
        
        
    fi 
    
	__options=${__options//--/;}
    


    
    if [[ -n "${__options}" ]]
    then
        
        mapfile -t -d \; ADDR <<< "$__options" # str is read into an array as tokens separated by IFS
        for __substr in "${ADDR[@]}"; do # access each element of array

            if [ ${#__substr} -gt 2 ]
            then
                if [[ ! ${__substr} =~ "rDNSatom"* ]]
                then

                    rest=$(string.green ${__substr#*=})
                    tagname=${__substr%%=*}
                    prefix=$(string.yellow $tagname)
                    
                    unset __changed
                    if [[ -n ${genre} || -n ${title} || -n ${album} || -n ${artist} ]]
                    then
                    
                        [[ -n ${!tagname} ]] && __changed="\t${!tagname}\n"
                    fi 
                    if [[ ! ${prefix} =~ "albumArtist" ]]
                    then
                        __out="${__out}\t${prefix}=${rest}\n${__changed}"
                    fi
                fi
            fi
        done
    else
        #__out="\t No Changes"
        string_color="string.light_red"
    fi


    file_name=$(eval "$string_color \"${filepath}${filename}\"")
	#file_name=$(string.red "${filepath}${filename}")
	#__out="$fileno: ${filename}\n"
    fileno=$(printf "%4d" "${fileno}")
    fileno=$(string.yellow "$fileno" "" 1)

    #__out="${fileno} $file_name\n${__out}"
    __out="${__out}"

	echo "${__out}"
}


function string.trans()
{
	local TEXT=$1
	local __text

	__text="${TEXT}"
#	__text=$(string.trans.do "${TEXT}")

	echo "${__text}"

}

function string.trans.do()
{
	local TEXT=$1
	local __text
	local RESULT

	RESULT=$(echo $TEXT | LC_COLLATE=C grep -r '[^ -~]')

	unset RESULT

	if [ -z "$RESULT" ]; then
		__text="${TEXT}"
	else
		__text=$(trans -b -no-warn -no-autocorrect ${TEXT})
	fi

	echo "${__text}"

}

# string.trim
function string.trim()
{
    local var=$1
    # remove leading whitespace characters
    var="${var#"${var%%[![:space:]]*}"}"
    # remove trailing whitespace characters
    var="${var%"${var##*[![:space:]]}"}"
    
    	last=${var#"${var%?}"}
        [[ ${last} == "," ]] && var=${var::${#var}-1}
    echo $var
}

function string.trim.last()
{
    local var=$1
	local char=$2

	last=${var#"${var%?}"}
	[[ ${last} == $char ]] && var=${var::${#var}-1}
    echo $var
}


function string.trim.dir()
{
	local source=$1
	local cut=$2
	local directory
	
	source=${source// /@}
	cut=${cut// /@}
	
	directory="${source//${cut}/}"
	[[ ! $directory == "" ]] && directory=$(string.trim.last $directory "/")
	
	if [[ $cut == "Teamskeet" && $source == *"Teamskeet@"* ]] 
	then 
		directory=${directory//@/${cut} }
	else
		directory=${directory//@/ }
	fi 

	echo $directory
	
}
# string.clean
function string.clean()
{
	local __text=$1
    __text="${__text#"${__text%%[!\']*}"}"
    __text="${__text%"${__text##*[!\']}"}"
    __text=$(string.trim ${__text})

	__text=${__text//\//}
	__text=${__text//\\/}

	__text=${__text//\"/}
	__text=${__text//\`/}

	__text=${__text//;/,}
	__text=${__text//\'/\\\'}
	__text=${__text//&/}
	__text=${__text//[[:alum:][:punct:][,]]/}


	echo ${__text}
}


function string.color()
{

	local __string=$1
	local __background=$2
	local __RAINBOWPALETTE=$3

	__color=${FUNCNAME[1]##*.}

	case ${__background} in
		"black" ) 			__background_code=";40";;
		"red" ) 			__background_code=";41";;
		"green" ) 			__background_code=";42";;
		"yellow" ) 			__background_code=";43";;
		"blue" ) 			__background_code=";44";;
		"magenta" ) 		__background_code=";45";;
		"cyan" ) 			__background_code=";46";;
		"light gray" ) 		__background_code=";47";;
		"dark gray" ) 		__background_code=";100";;
		"light red" ) 		__background_code=";101";;
		"light green" ) 	__background_code=";102";;
		"light yellow" ) 	__background_code=";103";;
		"light blue" ) 		__background_code=";104";;
		"light magenta" ) 	__background_code=";105";;
		"light cyan" ) 		__background_code=";106";;
		"white" ) 			__background_code=";107";;
		*) 					__background_code=";49";;
	esac

	case ${__color} in
		"black" )			__color_code="$__RAINBOWPALETTE;30${__background_code}";;
		"red" ) 			__color_code="$__RAINBOWPALETTE;31${__background_code}";;
		"green" ) 			__color_code="$__RAINBOWPALETTE;32${__background_code}";;
		"yellow" )			__color_code="$__RAINBOWPALETTE;33${__background_code}";;
		"blue" )			__color_code="$__RAINBOWPALETTE;34${__background_code}";;
		"purple" )			__color_code="$__RAINBOWPALETTE;35${__background_code}";;
		"cyan" )			__color_code="$__RAINBOWPALETTE;36${__background_code}";;
		"light_gray" )		__color_code="$__RAINBOWPALETTE;37${__background_code}";;
		"dark_gray" ) 		__color_code="$__RAINBOWPALETTE;90${__background_code}";;
		"light_red" ) 		__color_code="$__RAINBOWPALETTE;91${__background_code}";;
		"light_green" ) 	__color_code="$__RAINBOWPALETTE;92${__background_code}";;
		"light_yellow" ) 	__color_code="$__RAINBOWPALETTE;93${__background_code}";;
		"light_blue" ) 		__color_code="$__RAINBOWPALETTE;94${__background_code}";;
		"light_magenta" ) 	__color_code="$__RAINBOWPALETTE;95${__background_code}";;
		"light_cyan" )		__color_code="$__RAINBOWPALETTE;96${__background_code}";;
		"white" ) 			__color_code="$__RAINBOWPALETTE;97${__background_code}";;
		 * ) 				__color_code="$__RAINBOWPALETTE;39${__background_code}";;
	esac


	echo -e "\e[${__color_code}m$1\e[0m"
}


toSingleCharLines() {
  sed 's/\(.\)/\1\'$'\n''/g; s/\n$/\'$'\n''\\n/'
}

# Using stdin input, reassembles a string split into 1-character-per-line output
# by toSingleCharLines().
fromSingleCharLines() {
  awk '$0=="\\n" { printf "\n"; next} { printf "%s", $0 }'
}


string.diff()
{
 
 
local __strOne=$1
local __strTwo=$2


__output=$(diff --changed-group-format='${REDB}%>${RST}'  <(toSingleCharLines <<<"$__strOne") <(toSingleCharLines <<<"$__strTwo") | fromSingleCharLines )
 
 echo $__output
 
}    


function string.compare()
{
	local __string_a=$1
	local __string_b=$2


	if [[ ${__string_a} == ${__string_b} ]]
	then
		echo 1
	else
		echo 0
	fi
}

## attr
## version: 1.0.1 - attribute name
##################################################
attr() {
	##################################################
	local attribute_name
	##################################################
	temp() {
		echo attr-${attribute_name}-$( date +%s )-${RANDOM}
	}
	#-------------------------------------------------
	main() {
		_() {
        [[ -d "/tmp/plexdata/" ]] || mkdir -p "/tmp/plexdata/"  
        __tmp_colorfile="/tmp/plexdata/${2}"
			cat > ${__tmp_colorfile} << EOF
				string.${1}()
				{
					local __string="\$1"
					local __bg="\$2"
					local __rp="\$3"
					echo \$(string.color "\${__string}" "\${__bg}" "\${__rp}")
				}
EOF
			. ${__tmp_colorfile}

			rm ${__tmp_colorfile} --force #--verbose
		} ; _ "${attribute_name}" "$( temp )"
	}

	##################################################
	## $1 - attribute name
	##################################################
	if [ ${#} -eq 1 ]
	then
		attribute_name=${1}
		main
	else
		exit 1 # wrong args
	fi
}


function string.error()
{
	local __program=$1
	local __code=$2

	case "$__program" in
		"curl")
			echo ${curl_error[$__code]};;

	esac

}

#string.showMetaData
function string.showMetaData()
{

	local __file=$1
    local __show=$2

	#file: /home/bjorn/plex/XXX/test/Test Studio/mmf/hardcore-dp-on-the-pool-table-28534-720p_full_mp4.mp4
	#filename: hardcore-dp-on-the-pool-table-28534-720p_full_mp4.mp4
	#filepath: Test Studio/mmf/
	#fullpath: /home/bjorn/plex/XXX/test/Test Studio/mmf/

	file=$(file.get.path "$__file" "file")
	filename=$(file.get.path "$__file" "filename")
	fullpath=$(file.get.path "$__file" "fullpath")
	filepath=$(file.get.path "$__file" "filepath")


    fileno=$(printf "%4d" "${fileno}")
    fileno=$(string.yellow "$fileno" "" 1)
	file_name=$(string.blue "${filepath}${filename}")

    __out="${fileno}    $file_name\n"

	__genre_value=$(metadata.get.value "genre")
	__title_value=$(metadata.get.value "title")
	__studio_value=$(metadata.get.value "studio")
	__artist_value=$(metadata.get.value "artist")

    if [[ -n "${__SETONLY}" ]]
    then
    
        [[ ${__SETONLY} == "genre" ]] && _prev_genre=$(metadata.get.value "genre")
        [[ ${__SETONLY} == "title"  ]] && _prev_title=$(metadata.get.value "title")
        [[ ${__SETONLY} == "studio"  ]] && _prev_studip=$(metadata.get.value "studio")
        [[ ${__SETONLY} == "artist"  ]] && _prev_artist=$(metadata.get.value "artist")
    fi 
        
    if [[ -n "${__SHOW_TAGS}" || -n "$__show" ]]
    then
        __genre_string_tag=$(string.yellow "Genre" "" 1)
        __title_string_tag=$(string.yellow "Title" "" 1)
        __studio_string_tag=$(string.yellow "Studio" "" 1)
        __artist_string_tag=$(string.yellow "Actors" "" 1)


        [[ -n "${__genre_value}" ]] &&  __genre_out="\t   ${__genre_string_tag}  $(string.green $__genre_value  0 1) \n"
        [[ -n "${__title_value}" ]] &&  __title_out="\t   ${__title_string_tag}  $(string.green $__title_value  0 1) \n"
        [[ -n "${__studio_value}" ]] && __studio_out="\t   ${__studio_string_tag} $(string.green $__studio_value 0 1) \n"
        [[ -n "${__artist_value}" ]] && __artist_out="\t   ${__artist_string_tag} $(string.green $__artist_value 0 1) \n"
    
        __only_out="${__genre_out}${__title_out}${__studio_out}${__artist_out}"
        
        if [[ -n "${__SETONLY}" ]]
        then
            [[ ${__SETONLY} == "genre" ]] && __only_out=${__genre_out}
            [[ ${__SETONLY} == "title"  ]] && __only_out=${__title_out}
            [[ ${__SETONLY} == "studio"  ]] && __only_out=${__studio_out}
            [[ ${__SETONLY} == "artist"  ]] && __only_out=${__artist_out}
            
        fi 
        __out="${__out}${__only_out}"

    
    fi

	echo -e ${__out}
}

string.trimLen () {
    if (( "${#1}" > "$2" ))
    then
        text=$1
        search=":"
        first_process=${text%%$search*}
        last_process=${text##*$search}
        middle_text=${text:${#first_process}+1:${#text}-(${#last_process}+${#first_process}+2)}
        middle_process=${middle_text##*$search}
        echo "$first_process...$middle_process:$last_process"

    else
        echo "$1"
    fi

}