# shellcheck shell=bash
logr INFO "${__include_source_file}"

## For test and new features

function filedb.set.favorite()
{
	local __file=$1

	file=$(file.get.path "$__file" "file")
	filename=$(file.get.path "$__file" "filename")
	fullpath=$(file.get.path "$__file" "fullpath")
	filepath=$(file.get.path "$__file" "filepath")
	
    if [[ $(filedb.is.favorite "$filename") != 1 ]]
	then
        favorites_array+=("${filename}")
    fi  
    
    __options=$(tags.get.Option "studio"  $__options)
    __ret=$(metadata.write ${file} ${__options})

}

function filedb.is.favorite()
{
	local __file=$1
    
	filename=$(file.get.path "$__file" "filename")
	if [[ "${favorites_array[@]}" =~ "${filename,,}" ]]
	then
		echo 1
	else
        echo 0
    fi 
}

function filedb.save.favorite()
{

	favorites_array_string=$(declare -p favorites_array)
	favorites_array_string=${favorites_array_string//[/\\n[}
	echo -e $favorites_array_string > $__FAVORITE_NFO
}

function filedb.get.metadata()
{
	local __tag=$1
	
	echo $(meta.get.tag $file $__tag)

}