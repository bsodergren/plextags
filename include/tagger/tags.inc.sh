# shellcheck shell=bash
logr INFO "${__include_source_file}"

# tags.create.optionArg
function tags.create.optionArg() {
    local __tag_name=$1
    local __tag_value=$2
    local __options

    __tag_value="${__tag_value//\"/}"
    __tag_value="${__tag_value//__nt/}"

    if [[ ${__tag_name} == "artist" ]]; then
	
	 main.log "optionArg optionArg " "${__tag_value}" 
	 __tag_value=$(echo ${__tag_value}|tr ',' '\n'|uniq| tr '\n' ','| sed -e 's/,*$//')
	 main.log "optionArg optionArg " "${__tag_value}" 
        if [[ -z ${__DEBUG} ]]; then
            __xmlAtom=$(xml.get.atom "${__tag_name}" "$__tag_value")
        fi

        __options="${__options} --albumArtist=\"${__tag_value}\""
        __options="${__options} ${__xmlAtom}"
        __options="${__options}"
    fi

    if [[ ${__tag_value} != "sort" ]]; then
        __options="${__options} --${__tag_name}=\"${__tag_value}\""
    fi

    echo "${__options}"
}

# tags.get.value
function tags.get.value() {
    local __tag=$1
    local __get_studios=$2
    local __tag_value=""
    local __tag_option_name=""
    local __value_getMetafromFile=""
    local __value_getMetafromDB=""
    local __value_getTagData=""

    __tag_option_name=$__tag
    [[ $__tag == "studio" ]] && __tag_option_name="album"

    main.log "---------------------------------- " "" "1"

    main.log "Lookup data for " "${__tag}" "up"

    if [[ -n ${override[$__tag]} ]]
    then

        __tag_value=${override[$__tag]}
        __set_from="passed options"

        __add_value=${__tag_value%%:*}
        __new_tag_value=${__tag_value#*:}
        
        main.log "Adding / Removing tag " "${__add_value}" "up"
        main.log "Adding / Removing value " "${__new_tag_value}"
         unset override
        if [[ $__add_value =~ "add" ]]
        then
            #override[$__tag]=$__new_tag_value
           
            main.log "Adding new value " "${__new_tag_value}"



            case $__tag in
                "studio")
                    __orig_studio=$(tags.get.value "studio" 1)

                    if [[ $__orig_studio =~ .*$__new_tag_value.* ]]; then
                        __tag_value="${__orig_studio}"

                    else
                        __tag_value="${__orig_studio}/${__new_tag_value}"
                        #__tag_value=${__tag_value/\/$__new_tag_value/""}

                    fi

                    __new_tag_value=${__new_tag_value^}
                    ;;
                "genre")

                    __orig_genre=$(tags.get.value "genre" 1)
                    #					__tag_value=$(string.get.genre $__tag_value)
                    #__new_tag_value=$(string.get.genre $__new_tag_value)


                    if [[ $__orig_genre =~ .*"$__tag_value".* ]]; then
                        __tag_value="${__orig_genre}"

                    else

                        [[ ${__orig_genre} != "" ]] && __orig_genre="${__orig_genre},"
                        __tag_value=${__orig_genre/$__new_tag_value,/""}


                        __tag_value="${__tag_value}${__new_tag_value}"
                    #
                    fi;;

            esac
            
                    __tag_value=${__tag_value#/}
   echo "${__tag_value}"
            exit
        fi

        if [[ $__add_value =~ "rm" ]]
        then
        
            unset override
            
            main.log "Removing value Studio " "${__new_tag_value}"
 main.log "override override override " "${override}"
            case $__tag in
                "studio")
                    __orig_studio=$(tags.get.value "studio" 1)
                    
                    main.log "original Studio " "${__orig_studio}"
                    if [[ $__orig_studio =~ .*$__new_tag_value.* ]]
                    then
                        main.log "__new_tag_value Studio " "${__new_tag_value}"

                        __refresh=1 
                        __tag_value=${__orig_studio/${__new_tag_value}/""}

                        __tag_value=${__tag_value^}

                        __tag_value=${__tag_value%*/}
                        [[ $__tag_value == "" ]] && __tag_value="__nt"
                        
                    else 
                            __tag_value=""
                        
                    fi 
                    
                     main.log "__tag_value Studio $__refresh -- " "${__tag_value}"
                    ;;
                    
            esac
            
            echo "${__tag_value}"
            exit

        fi
        
       
    else


        __value_getTagData=$(tags.get.data "$__tag")
        __value_getTagData=${__value_getTagData//\"/}

      
        
        __value_getMetafromFile=$(metadata.get.value "$__tag")
        __value_getMetafromFile=${__value_getMetafromFile//\"/}
        
        __value_getMetafromDB=$(filedb.get.metadata "$__tag")
        __value_getMetafromDB=${__value_getMetafromDB//\"/}
  
        if [[ -n ${__get_studios} ]]
        then
            __value_getMetafromFile=$(string.trim "$__value_getMetafromFile")
            echo "${__value_getMetafromFile}"
            exit
        fi
        
        main.log "tags.get.data " "${__value_getTagData}" "up"
        main.log "filedb.get.metadata " "${__value_getMetafromDB}"  
        main.log "metadata.get.value " "${__value_getMetafromFile}"
        
        
        if [[ -n "$__REFRESH" || $__refresh == 1 ]]
        then
            __tag_value=$__value_getTagData
            __set_from="Refresh from __value_getTagData"

        else

            declare __if_path="$__tag::"
            if
                [[ -z ${__value_getTagData} && -z ${__value_getMetafromFile} && -z ${__value_getMetafromDB} ]]
            ## TagData == FALSE	## MetaData == FALSE	## DB Data == FALSE
            then

                __if_path="${__if_path}A"
                __if_path="${__if_path},1"
                __tag_value=""
                __set_from="No $__tag_option_name set"

            elif
                [[ -n ${__value_getTagData} && -z ${__value_getMetafromFile} && -z ${__value_getMetafromDB} ]]
            ## TagData == TRUE ## MetaData == FALSE ## DB Data == FALSE
            then

                __if_path="${__if_path}B"
                __if_path="${__if_path},1"
                __tag_value=$__value_getTagData
                __set_from="__value_getTagData"

            elif
                [[ -z ${__value_getTagData} && -n ${__value_getMetafromFile} && -z ${__value_getMetafromDB} ]]
            ## TagData == FALSE ## MetaData == TRUE ## DB Data == FALSE
            then
                __if_path="${__if_path}C"
                __if_path="${__if_path},1"
                #__tag_value=${__value_getMetafromFile}
                #__set_from="__value_getMetafromFile"

            elif
                [[ -z ${__value_getTagData} && -z ${__value_getMetafromFile} && -n ${__value_getMetafromDB} ]]
            ## TagData == FALSE ## MetaData == FALSE ## DB Data == TRUE
            then
                __if_path="${__if_path}D"
                __if_path="${__if_path},1"
                __tag_value=$__value_getMetafromDB
                __set_from="__value_getMetafromDB"

            elif
                [[ -n ${__value_getTagData} && -n ${__value_getMetafromFile} && -z ${__value_getMetafromDB} ]]
            ## TagData == TRUE ## MetaData == TRUE ## DB Data == FALSE
            then
                __if_path="${__if_path}E"
                if [[ $__value_getTagData != $__value_getMetafromFile ]]
                then
                    __if_path="${__if_path},1"
                    if [[ $__value_getMetafromFile == "" ]]
                    then
                        __if_path="${__if_path},2"
                        __tag_value=$__value_getTagData
                        __set_from="__value_getTagData"
                   elif [[ $__value_getTagData == "" ]]
                   then
                        __tag_value=$__value_getMetafromFile
                        __set_from="__value_getMetafromFile"
                        __if_path="${__if_path},3"
                    else
                        __tag_value=$(tags.compare.values $__value_getMetafromFile $__value_getTagData ) # $__tag $__tag)
                        
                         if [[ $__tag_value != $__value_getMetafromFile ]]
                        then
                            __set_from="tags.compare.values"
                            __if_path="${__if_path},4"
                        else 
                            unset __tag_value
                            __if_path="${__if_path},5"
                            __set_from="All are the same"
                        fi
                        
                        
                    fi
                    
                else
                    __if_path="${__if_path},6"
                    __set_from="All are the same"                
                fi 

            elif
                [[ -n ${__value_getTagData} && -z ${__value_getMetafromFile} && -n ${__value_getMetafromDB} ]]
            ## TagData == TRUE ## MetaData == FALSE ## DB Data == TRUE
            then
                __if_path="${__if_path}F"

                if [[ $__value_getTagData != "$__value_getMetafromDB" ]]; then
                    __if_path="${__if_path},1"
                    if [[ $__value_getTagData < $__value_getMetafromDB ]]; then
                        __if_path="${__if_path},1"
                        __tag_value=$__value_getMetafromDB
                        __set_from="__value_getMetafromDB"
                    elif [[ $__value_getTagData > $__value_getMetafromDB ]]; then
                        __if_path="${__if_path},2"
                        __tag_value=$__value_getTagData
                        __set_from="__value_getTagData"
                    elif [[ $__value_getTagData == "$__value_getMetafromDB" ]]; then
                        ## are they the same because of the stupid ,?
                        __if_path="${__if_path},3"
                        __tag_value=$__value_getMetafromDB
                        __set_from="nothing"
                    else
                        __if_path="${__if_path},4"
                    fi
                elif [[ $__value_getTagData == "$__value_getMetafromDB" ]]; then
                    __if_path="${__if_path},2"
                    if [[ -z ${__value_getMetafromFile} ]]; then
                        __if_path="${__if_path},1"
                        __tag_value=$__value_getTagData
                        __set_from="__value_getTagData"
                    else
                        __if_path="${__if_path},2"

                    fi
                fi

            elif
                [[ -z ${__value_getTagData} && -n ${__value_getMetafromFile} && -n ${__value_getMetafromDB} ]]
            ## TagData == FALSE ## MetaData == TRUE ## DB Data == TRUE
            then
                __if_path="${__if_path}G"
                if [[ $__value_getMetafromFile != "$__value_getMetafromDB" ]]; then
                    __if_path="${__if_path},1"
                    __tag_value=$__value_getMetafromDB
                    __set_from="__value_getMetafromDB"
                else
                    __if_path="${__if_path},2"
                    __set_from="__value_getMetafromDB & __value_getMetafromFile are the same"
                fi

            elif
                [[ -n ${__value_getTagData} && -n ${__value_getMetafromFile} && -n ${__value_getMetafromDB} ]]
            ## TagData == TRUE ## MetaData == TRUE ## DB Data == TRUE
            then
                __if_path="${__if_path}H"
                if [[ $__value_getTagData == "$__value_getMetafromDB" && \
                    $__value_getMetafromFile != "$__value_getMetafromDB" ]]; then
                    __if_path="${__if_path},1"
                    __tag_value=$__value_getTagData
                    __set_from="__value_getTagData"
                elif [[ $__value_getTagData != "$__value_getMetafromDB" && \
                    $__value_getMetafromFile == "$__value_getMetafromDB" ]]; then
                    __if_path="${__if_path},2"
                  #  __tag_value=$__value_getMetafromDB
                    __set_from="Metatag is correct"
                elif [[  $__value_getTagData != "$__value_getMetafromDB" && \
                    $__value_getMetafromFile != "$__value_getMetafromDB" ]]; then
                    __if_path="${__if_path},3"
                    __tag_value=$__value_getMetafromDB
                    __set_from="__value_getMetafromDB"
                else
                    __if_path="${__if_path},4"
                    __set_from="All are the same"
                fi
            fi
        fi
    fi


   main.log "Set by Path " "${__if_path}" 
   main.log "Set from Method " "${__set_from}"
   [[ ! "${__tag_value}" == "" ]] && main.log "$__tag value is " "${__tag_value}"


    if [[ -n ${__tag_value} ]]; then
        __tag_value=$(string.trim "$__tag_value")
        echo "${__tag_value}"
    else
        echo ""
    fi
    

}

# tags.get.Option
function tags.get.Option() {
    local __tag=$1
    local __options

    local __tag_option_name
    __tag_option_name=$__tag

    [[ $__tag == "studio" ]] && __tag_option_name="album"

    __tagValues=$(tags.get.value "${__tag}")


    main.log "__tagValues for " "${__tagValues}" 

	# [[ $__tag == "genre" ]] && __tagValues=$(string.get.genre $__tagValues)
    

    [[ -n ${__tagValues} ]] &&  __options=$(tags.create.optionArg ${__tag_option_name} "${__tagValues}")

    echo "${__options}"

}

# tags.get.data
function tags.get.data() {
    local __tag=$1
    local __noptions=$2
    local cmdFunction

    titlestudio=$(filedb.get.studio "title" 1)


    titlestudio_key=${titlestudio//" "/"_"}


    __tag=${__tag^}

    cmdFunction="file.get.${__tag,,}"
    
    main.log "cmdFunction for " "${cmdFunction}" 

    __value=$(eval "$cmdFunction")

 main.log "cmdFunction for __value " "${__value}" 
    [[ -n ${__noptions} ]] && __value=$(tags.create.optionArg "$__tag" "${__value}")



    echo "${__value}"
}

# tags.compare.values
function tags.compare.values() {
    local __string_a=$1
    local __string_b=$2
    local __tag_a="${3:-}"
    local __tag_b="${4:-}"
    local __out
    local __string_path
    local __string_from

 
    if [[ -n $__tag_a ]]; then
        ___string_a=$(filedb.read "$__string_a" "$__tag_a" true)
        [[ $___string_a != "" ]] && __string_a=$___string_a
        
    fi

    if [[ -n $__tag_b ]]; then
        ___string_b=$(filedb.read "$__string_b" "$__tag_b" true)
        [[ $___string_b != "" ]] && __string_b=$___string_b
    fi
    
    __string_a_tmp="${__string_a//\"/}"
    __string_a_tmp="${__string_a_tmp// /}"
    __string_a_tmp="${__string_a_tmp//,/}"
    __string_a_tmp="${__string_a_tmp,,}"

    __string_b_tmp="${__string_b//\"/}"
    __string_b_tmp="${__string_b_tmp// /}"
    __string_b_tmp="${__string_b_tmp//,/}"
    __string_b_tmp="${__string_b_tmp,,}"

       

    if [[ -n ${__string_a_tmp} ]]; then
        __string_path="${__string_path},1"
        if [[ ${#__string_a_tmp} -gt ${#__string_b_tmp} ]]; then
            __string_path="${__string_path},3"
            __string_from="__string_a"
            __out="${__string_a}"
        elif [[ ${#__string_a_tmp} -lt ${#__string_b_tmp} ]]; then
            __string_path="${__string_path},4"
            __string_from="__string_b"
            __out="${__string_b}"
        else
            __string_path="${__string_path},5"
            __string_from="Both the Same"
            __out="${__string_a}"
        fi
    else
        __string_path="${__string_path},7"
        __string_from="__string_b"
        __out="${__string_b}"
    fi
    
    [[ "$__string_a_tmp" == "deleted" ]] && __out="${__out},${___string_a}"
    [[ "$__string_b_tmp" == "deleted" ]] && __out="${__out},${__string_b}"

    if [[ $(filedb.is.favorite "$filename") == 0 ]]
    then
        __out="${__out/\/Favorite/}"
    fi

    
    echo "$__out"
}

function tag.is.missing() {
    local file=$1
    local __tags="${2:-ALL}"
    local __genre
    local __studio
    local __artist
    local __title
    local __isset=1

    case ${__tags,,} in
        "all")
            __genre=$(metadata.get.value "genre")
            __studio=$(metadata.get.value "studio")
            __title=$(metadata.get.value "title")
            __artist=$(metadata.get.value "artist")





            [[ $__genre == "" ]] && __isset=0
            [[ $__studio == "" ]] && __isset=0
            [[ $__title == "" ]] && __isset=0
            [[ $__artist == "" ]] && __isset=0

            ;;
        "genre")
            __genre=$(metadata.get.value genre)


            [[ $__genre == "" ]] && __isset=0
            ;;
        "studio")
            __studio=$(metadata.get.value "studio")
            [[ ${__studio,,} == "unknown" ]] && __studio=""

            [[ $__studio == "" ]] && __isset=0
            ;;
        "title")
            __title=$(metadata.get.value "title")

            [[ $__title == "" ]] && __isset=0
            ;;
                  "artist")
            __artist=$(metadata.get.value "artist")

            [[ $__artist == "" ]] && __isset=0
            ;;
    esac

    if [[ $__isset == 1 ]]; then

        echo "0"
    else

        echo "1"
    fi

}
