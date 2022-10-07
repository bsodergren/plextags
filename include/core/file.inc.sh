# shellcheck shell=bash
logr INFO "${__include_source_file}"


#file.name.backup
function file.name.backup()
{
	local __filename=$1

	local ext
	local __idx

	__idx=${__filename##*.}
    if ! is_int $__idx
    then
    
        __idx=0
    fi 
    

	if [[ -f "${__filename}" ]]
	then
		((__idx++))
        
        ext=${__filename##*.}
        if is_int $ext
        then
            __filename="${__filename%.*}.${__idx}"
        else 
            __filename="${__filename}.${__idx}"
        fi
        
		__filename=$(file.name.backup ${__filename})
	fi
	echo "$__filename"
}

# file.get.path
function file.get.path()
{
	local __file=$1
	local __type=$2
	local __filename
	local __fullpath
	local __filepath
	local __out

	#file: /home/bjorn/plex/XXX/test/Test Studio/mmf/hardcore-dp-on-the-pool-table-28534-720p_full_mp4.mp4
	#filename: hardcore-dp-on-the-pool-table-28534-720p_full_mp4.mp4
	#filepath: Test Studio/mmf/
	#fullpath: /home/bjorn/plex/XXX/test/Test Studio/mmf/

	if [[ -f $__file ]] 
	then
		__file=$(realpath ${__file})
	else 
		__file=${__file##*/}
    fi

	case $__type in
		"file")
			__out=${__file};;
		"filename")
			__out=$(basename -- ${__file});;
		"fullpath")
			__filename=$(basename -- ${__file})
			__out=${__file/$__filename/""};;
		"filepath")
			__filename=$(basename -- ${__file})
			__fullpath=${__file/$__filename/""}
			__out=${__fullpath/$directory/""};;
		"studiodir")
			__studio_dir=$(filedb.get.studio)
			__filename=$(basename -- ${__file})
			__filepath=${__filepath/$__studio_dir/""}
			__out=${__filepath}${__filename};;
	esac


	echo $__out
}

function file.comparedate()
{
    
    if [ ! -f $1 ]; then
        echo 1
        exit
    fi
    
    local __age="${2:-100}"
    
    MAXAGE=$(bc <<< $__age) # seconds in 28 hours
    # file age in seconds = current_time - file_modification_time.
    FILEAGE=$(($(date +%s) - $(stat -c '%Y' "$1")))
    test $FILEAGE -lt $MAXAGE && {
        echo 0
        exit
    }
    echo 1
}

#file.temp.name
function file.temp.name()
{
	local __file=$1
	local __tmp_filename
	local __tag_file
    local __prefix="${2:-}"
   
    __file=${__file//\'/}
	__tmp_filename=$(file.get.path $__file "filename")
    
    [[ -d "/tmp/plexdata/" ]] || mkdir -p "/tmp/plexdata/"    
	__tag_file="/tmp/plexdata/${__prefix}${__tmp_filename}.tmp"
    
    ## [[ -z "$__prefix" ]] && 
    file.prepend $__TEMP_FILE_LIST $__tag_file
	echo $__tag_file
}

function file.temp.clean()
{
	if [[ -f $__TEMP_FILE_LIST  ]]
	then 
		while read -r line
		do
			if [[ $line != "" ]]
			then
				# [[ -f "$line" ]] && echo "$line"
				[[ -f "$line" ]] && rm "$line"
			fi 
		done < $__TEMP_FILE_LIST 
	fi 
}


#file.temp.del
function file.temp.del()
{
	local __file=$1
    local __prefix="${2:-}"
    
    __file=${__file//\'/}
	__tmp_tag_file=$(file.temp.name $__file $__prefix)
    
	[[ -f $__tmp_tag_file ]] && rm $__tmp_tag_file

}

function file.write()
{
    local __file=$1
    local __string=$2
    
}
function file.prepend()
{
	local __file=$1
	local __string=$2
        
    __file=${__file//\'/}
    
    if [[ -f $__file ]]
    then
        __newfile=$(mktemp /tmp/plexdata/abc-script.XXXXXX)

        echo -e "${__string}" > $__newfile
        while read -r line
        do
         echo "$line"
        done < $__file >> $__newfile
        mv $__newfile $__file
    
    else
        touch "$__file"
        echo -e "${__string}\n" > "$__file"
    fi
       
}

function file.lastModified()
{
	local __file=$1
	local __curr
	
	__curr=$(file.get.path $__file "file")

	__stamp=$(stat -c %z "${__curr}")
	__stamp=$(date +"%Y-%m-%d %T" -d $__stamp )
	
	echo $__stamp 
	
}

function file.get.value()
{
	local __tag="${1}"
	local __update="${2}"
	local __value=""
	local cmdFunction
	
	[[ -z $__update ]] && __value=$(metadata.get.value "$__tag")

		cmdFunction="file.get.${__tag,,}"

		if [[ -z "${__value}" ]] 
		then 
			__value=$(eval "$cmdFunction" )
			__value="${__value}"
		fi
	
		echo "\"${__value}\""		
}


function file.move()
{

	local source=$1
	local dest=$2
	local source_dir
	local dest_dir
	
	source_dir=$(file.get.path $source "filepath")
	dest_dir="${dest}/${in_dir}/${source_dir}"
	
	mkdir -p "${dest_dir}"
	__=$(mv "${source}" "${dest_dir}")
	

}