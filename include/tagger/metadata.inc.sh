# shellcheck shell=bash
logr INFO "${__include_source_file}"

# metadata.get.value
function metadata.get.value()
{
	local __tag=$1
	local idx

    
	case "$__tag" in
		"studio") regex='(alb).*contains\:\ (.*)' ;;
		"genre") regex='(gen).*contains\:\ (.*)' ;;
		"title") regex='(nam).*contains\:\ (.*)' ;;
		"artist") regex='(\"©ART\").*\:\ (.*)' ;;
        "keyword") regex='(keyw).*\:\ (.*)' ;;
	esac
   
	__tmp_tag_file=$(file.temp.name $file)
    
    _val=$(file.comparedate "${__tmp_tag_file}" )
	if [[ $_val == 1  ]]
	then
		$(AtomicParsley "${file}"  -t + > $__tmp_tag_file)
	fi

	IFS=$'\n'
	arr=()
	mapfile -t arr < $__tmp_tag_file
    
    for ((idx = 0; idx < ${#arr[@]}; idx++))
	do
   
		[[ ${arr[$idx]} =~ $regex ]] # $pat must be unquoted
		value="${BASH_REMATCH[2]}"
		if [[ -n "${value}" ]]
		then
    
			echo "$value"

		fi
	done

}

# metadata.write
function metadata.write()
{
	local __file=$1
	local __options=$2
	local __out
	local __filename
	local __filepath


	if [[ -z "${__DEBUG}" ]]
	then

        eval AtomicParsley \"${__file}\" ${__options} --overWrite

     if [[ $? == 1 ]]
		then
            printf "\n"            
			__filename=$(file.get.path $__file "filename")
			__filepath=$(file.get.path $__file "filepath")
            file.prepend $__BROKEN_FILES $__file
			echo "Something is wrong with ${__filename}"
			metadata.fix.file	${__file} ${__options}
            printf "\n"
		fi
	fi
    
	printf "\n"
}

function metadata.set.tag()
{
	local __tag_list="$1"
	local __options="$2"
	local __array=()
	local __value

	mapfile -t -d \, __array <<< "$__tag_list"
	for __value in ${__array[@]}
	do
		__options=$(tags.get.Option $__value $__options)
	done

	echo ${__options}
}

function metadata.delete.tag()
{
	local __tag_list="$1"
	local __array=()
	local __value


            mapfile -t -d \, __array <<< "$__tag_list"

            #Print the words after the split
            for __value in ${__array[@]}
            do
                case "$__value" in
                    "studio")
                            __options="$__options --album=\"\"";;
                    "genre")
                            __options="$__options --genre=\"\"";;
                    "title")
                            __options="$__options --title=\"\"";;
                    "artist")
                            __options="$__options --albumArtist=\"\""
                            __options="$__options --artist=\"\""
                            __xmlAtom=$(xml.get.atom "${value}" "")
                            __options="${__options} ${__xmlAtom}";;
                    "keyword")
                            __options="$__options --keyword=\"\"";;
                            "ALL")
                            __options=" --metaEnema ";;
                esac
            done
        echo ${__options}

        
	
}


function metadata.fix.file()
{
	local __file=$1
	local __options=$2
    local __filename
	__filename=$(file.get.path $__file "filename")
 
    __filepath=$(file.get.path $__file "filepath")

	eval ffmpeg -hide_banner -loglevel error -i \"${__file}\"  -codec copy    \"${__file}.mp4\"
    
    if [[ -f "${__file}" ]]
    then 
        dmg_dir="${__PLEX_HOME}/dmg/${directory}/${__filepath}"
        mkdir -p "${dmg_dir}"

        mv "${__file}" 	"${dmg_dir}${__filename}"
    fi 
    
    [[ -f "${__file}.mp4" ]] &&	 mv "${__file}.mp4" "${__file}"

    eval AtomicParsley \""${__file}\"" ${__options} --overWrite
    
}
