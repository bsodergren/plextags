logr INFO "${__include_source_file}"


function sql.build.array()
{
	__sql_query="SELECT CONCAT(fullpath,filename) as file_name FROM ${__MYSQL_VIDEO_TABLE} WHERE filename IS NOT NULL"
	
	res=$(mysql.query ${__sql_query})
	echo $res
}

#
# update `studios2` SET studio=(@temp:=studio), studio = studio_a, studio_a = @temp WHERE (studio_a) IS NOT NULL;
#

function sql.get.tag()
{
	local __file=$1
	local __tag=$2
	local __timestamp=$3
	local __key=$(sql.get.key "$__file")
	[[ $(sql.file.exists ${__file}) -eq 0 ]] && main.log "file does not exists" && exit
	local __date

	local __sql_query_add=""
	if [[ -z $__timestamp ]]
	then
		filename=$(file.get.path "${__file}" "file")
 		__date=$(file.lastModified  $filename)
		__sql_query_add=" AND last_updated > '${__date}'"
	fi
	
	__sql_query="SELECT ${__tag}  FROM ${__MYSQL_VIDEO_TABLE} WHERE video_key = '${__key}' ${__sql_query_add}"
	res=$(mysql.query ${__sql_query})
	if [[ $res != NULL ]]
	then
		echo $res
	fi 	
}

function sql.set.favorite()
{
	local __file=$1
	local __key=$(sql.get.key "$__file")
	[[ $(sql.file.exists ${__file}) == 0 ]] && main.log "file does not exists" && exit
	
	file=$(file.get.path "$__file" "file")
	filename=$(file.get.path "$__file" "filename")
	fullpath=$(file.get.path "$__file" "fullpath")
	filepath=$(file.get.path "$__file" "filepath")
	if [[ $(filedb.is.favorite "$filename") == 1 ]]
	then
		__sql_query="UPDATE ${__MYSQL_VIDEO_TABLE} SET favorite=1 WHERE video_key = '${__key}'";
		res=$(mysql.query ${__sql_query})
	fi

}

function sql.delete.tag()
{
	local __file=$1
	local __tag=$2
	local __key=$(sql.get.key "$__file")
	[[ $(sql.file.exists ${__file}) == 0 ]] && main.log "file does not exists" && exit
	
	main.log "file exists, deleting tag" $__tag


	__query_part="${__tag} = null"
	__sql_query="UPDATE ${__MYSQL_VIDEO_TABLE} SET ${__query_part} WHERE video_key = '${__key}'";

	res=$(mysql.query ${__sql_query})
}

function sql.set.tag()
{
	local __file=$1
	local __tag=$2
	local __value=$3
	local __key=$(sql.get.key "$__file")
	[[ $(sql.file.exists ${__file}) == 0 ]] && main.log "file does not exists" && exit

	if [[ -n $__value ]]
	then
		if [[ "${__value}" =~ "|" ]]
		then
			mapfile  -t -d"|" -c1 __tagArray <<< "${__tag}"
			mapfile  -t -d"|" -c1 __valueArray <<< "${__value}"
		else
			__valueArray=("$__value")
			__tagArray=("$__tag")
		fi
		tLen=${#__tagArray[@]}

		
		for (( q=0; q < tLen; q++ ))
		do
			__v="${__valueArray[$q]}"
			__t="${__tagArray[$q]}"
			__v=$(string.trim ${__v//\"/})
			__t=$(string.trim ${__t//\"/})

			
			if [[ -n $__v ]]
			then


				if [[ ${__t} == *"studio"* ]]
				then
					$(sql.set.favorite ${__file})
					if [[ "${__v}" == *"Favorite"* ]]
					then
						__query_part="favorite = 1"
						__v=${__v//\/Favorite/}
					fi 
					
					[[ -z "${filepath}" ]] && filepath=$(file.get.path "$__file" "filepath")
					[[ -z "${fullpath}" ]] && fullpath=$(file.get.path "$__file" "fullpath")

					[[ -z "${file}" ]] && file=$__file
					[[ -z "${filename}" ]] && filename=$__file
					[[ -z "${__genre}" ]] && __genre=$(file.get.genre 1)



					studiopath=$(string.trim.dir ${fullpath} ${studio_directory} )

					studiopath=$(string.trim.dir ${studiopath} ${__genre} )

					# [[ $studiopath == *"Misc"* ]] && studiopath=$(string.trim.dir ${studiopath} "Misc" )
					[[ $studiopath == *"Favs"* ]] && studiopath=$(string.trim.dir ${studiopath} "Favs" )
					[[ $studiopath == *"Sort"* ]]  && studiopath=$(string.trim.dir ${studiopath} "Sort" )
					[[ $studiopath == *"Favorites"* ]]  && studiopath=$(string.trim.dir ${studiopath} "Favorites" )
					[[ $studiopath == *"Channels"* ]]  && studiopath=$(string.trim.dir ${studiopath} "Channels" )
					[[ $studiopath == *"Downloaded"* ]]  && studiopath=$(string.trim.dir ${studiopath} "Downloaded" )
					
					studiopath="${studiopath%%\/*}"
					unset __studio

				

					__studio=$(filedb.get.studio "studio")
					
					__studio_a=$(string.trim.dir ${__v} "${studiopath}" )
					__studio_a="${__studio_a/\//}"

					if [[ $__studio_a == $__studio ]]
					then
						__studio=$studiopath
					fi
					
					[[ -n $__studio ]] && __query_part="studio = \"${__studio}\",${__query_part}"
					[[ -n $__studio_a ]] && __query_part="studio_a = \"${__studio_a}\",${__query_part}"
					[[ -z $__studio_a ]] && __query_part="studio_a = NULL ,${__query_part}"

								

					
				else
					printf -v __v "%q" "${__v}"
					__v="'${__v}'"
					__v=$(string.trim ${__v//\ / })
					__t="${__t} = ${__v}"
					__query_part="${__t},${__query_part}"
				fi 
			fi
		done
		
		if [[ -n $__query_part ]]
		then 
			last=${__query_part#"${__query_part%?}"}
			[[ ${last} == "," ]] && __query_part=${__query_part::${#__query_part}-1} 


			__sql_query="UPDATE ${__MYSQL_VIDEO_TABLE} SET ${__query_part} WHERE video_key = '${__key}'";
			#echo $__sql_query
			
			res=$(mysql.query ${__sql_query})
		fi
	fi

}


function sql.update.tag()
{

	local __file=$1
	local __tag=$2
	local __value=$3
	local __key=$(sql.get.key "$__file")
	[[ $(sql.file.exists ${__file}) == 0 ]] && main.log "file does not exists" && exit

# SELECT * FROM `studios` WHERE filename LIKE 'lusthd_nadya_nice_full_hi_1080hd.mp4' AND `last_updated` < '2022-09-03 10:27:41'
# stat -c '%y' lusthd_nadya_nice_full_hi_1080hd.mp4 |date +"%F %T"

	printf -v __value "%q" "${__value}"
	__value="'${__value}'"
	
	__query_part="${__tag} = ${__value}"
	__sql_query="UPDATE ${__MYSQL_VIDEO_TABLE} SET ${__query_part} WHERE video_key = '${__key}'";
	res=$(mysql.query ${__sql_query})
}


function sql.get.key()
{
	local __file=$1
	

	__file=$(file.get.path "${__file}" "filename")
	__file_key=$(echo   -n   $__file | md5sum | awk '{print $1}')
	__file_key="x${__file_key}"
	
	echo "${__file_key}"

}

function sql.lastUpdate()
{
	local __file=$1
	local __key=$(sql.get.key "$__file")
	local res
	local __date

	filename=$(file.get.path "${__file}" "file")

	__date=$(file.lastModified  $filename)
	__sql_query="SELECT count(*)  FROM ${__MYSQL_VIDEO_TABLE} WHERE video_key = '${__key}' AND last_updated < '${__date}' ORDER BY studio DESC"
	res=$(mysql.query ${__sql_query})
	echo $res
}


function sql.file.exists()
{
	local __key=$(sql.get.key "$1")
	
	__tmp__key_file=$(file.temp.name $__key)
	if [[ -f $__tmp__key_file ]] 
	then
		file_exists_state=$(cat $__tmp__key_file)
		
	else
		__sql_query="SELECT count(*) FROM ${__MYSQL_VIDEO_TABLE} WHERE video_key = '${__key}'"
		file_exists_state=$(mysql.query ${__sql_query})
		
		if [[ $file_exists_state -ge 1 ]]
		then
			echo  ${file_exists_state} > $__tmp__key_file
		fi	
		
	fi
	echo $file_exists_state

}


function sql.add.file()
{
	local __file=$1
	local __key=$(sql.get.key "$1")
	
	if [[ $(sql.file.exists ${__file}) -ge 1 ]]
	then 
		main.log "file exists..  "
		echo 0
	else 
		__sql_query="INSERT INTO ${__MYSQL_VIDEO_TABLE} (video_key) VALUES ('${__key}')"
		res=$(mysql.query "${__sql_query}")

		__tmp__key_file=$(file.temp.name $__key)
		echo 1 > $__tmp__key_file
		echo 1
	fi
}

function sql.get.filelist()
{

	__sql_query="SELECT  CONCAT(fullpath,filename) as file_name FROM ${__MYSQL_VIDEO_TABLE} WHERE filename IS NOT NULL"
	res=$(mysql.query ${__sql_query}  )	
	echo $res
}


function sql.delete.file()
{
	local __file=$1
	local __key=$(sql.get.key "$__file")	

	local res
	
	[[ $(sql.file.exists ${__file}) == 0 ]] && exit

	__sql_query="DELETE FROM ${__MYSQL_VIDEO_TABLE} WHERE video_key = '${__key}'"
	
	res=$(mysql.query ${__sql_query}  )	
	echo $res

}
