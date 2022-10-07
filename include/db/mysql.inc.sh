# shellcheck shell=bash
logr INFO "${__include_source_file}"

function mysql.query()
{
	local __sql_query=$1	
	local __result
	
	#printf -v __sql_query "%q" "$__sql_query"	
	main.log "MySQL Query" "${__sql_query}"
	__result=$(mysql ${__MYSQL_DATABASE} -N -e "$__sql_query" 2>&1 )

	if [ ! $? = 0 ]
	then
		main.log "MySQL ERROR" "${__result}"
		echo $__result
		exit
	fi 
	
	echo $__result 	
}


function mysql.deletekey()
{
    local __key=$1
    local __col=$2
    local __result
    
    
    if [[ -n ${__col} ]]
    then
        __col="video_${__col}"
    fi
    
    __sql_query="DELETE ${__col} FROM ${__MYSQL_PORNHUB_TABLE} WHERE video_key = ${__key}"
    
    __result=$(mysql.query ${__sql_query}  )
    echo $__result 

}

function mysql.get.TagValue()
{
	local __filename=$1
	local __tag=$2
	local __ph_key
	local __result

	__ph_key=$(pornhub.filekey "$__filename")

    
    
    __tmp_tag_file=$(file.temp.name "${__ph_key}" "query_")

    _val=$(file.comparedate "${__tmp_tag_file}" 10 )

	if [[ $_val == 1  ]]
	then
        __select_query="CONCAT_WS('|',video_url,video_title,video_artist,CONCAT_WS(';',genres_a,genres_b) ) as video_data"
        sql="SELECT ${__select_query}  FROM ${__MYSQL_PORNHUB_TABLE} WHERE video_key = ${__ph_key}";

        __result_tmp=$(mysql.query ${sql}  )
        main.log "new Pornhub SQL query" 
        
        echo $__result_tmp > $__tmp_tag_file
    fi
    

    __result_tmp=$(head -n 1 "${__tmp_tag_file}")

    main.log "Pornhub temp results" "${__result_tmp}"
    
    IFS="|"
    __result=(${__result_tmp// / })

    artist=${__result[2]}
    url=${__result[0]}
    title=${__result[1]}    
    genre=${__result[3]}
    studio=""
    
    main.log "Pornhub ${__tag} results" "${!__tag}"
    
    echo ${!__tag}
    
}