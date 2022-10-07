
directory_regex='(Test|BiSexual|Pornhub|Studios|Videos)\/(Channels|Amateur|Downloaded)?\/?([A-Za-z0-9_\. ]{0,})/'
studio_regex='\/?([a-zA-Z 0-9 -]*|[a-zA-Z 0-9 ~]*|[a-zA-Z 0-9 &]*)\/*$'
date_regex='([0-9]{0,4}-[0-9]{0,2}-[0-9]{0,2})'
#genre_regex='[a-zA-Z \/]*\/(group?\/orgy|group?\/fmmm|group?\/fffm|mmf|mff|single|only girls|comp|bimale|trans|blowjob|compilation)(.*)?(\/*.mp4)?'
genre_regex='[a-zA-Z _0-9\.\/]*\/(group|mmf|mff|single|only girls|bimale|trans|only blowjobs|compilation|Bisexual male|step fantasy|amateur|threesome)(.*)?(\/*.mp4)?'
info_file_regex="\"?(.*)\"?,\"?(.*)\"?,\"?(.*)\"?,\"?(.*)\"?,\"?(.*)\"?"



declare -a __tag_list=("title" "genre" "studio" "artist")
#declare -a __genre_list_array=("amateur" "mmf" "mff" "group" "single" "only girls" "bimale" "trans" "only blowjobs" "compilation" "bisexual male" "bisexual" "step fantasy") 


#declare -a favorites_array

declare -A pattern
declare -A namesPattern
declare -A delimiterChar
declare -A artist_match
declare -A __file_info_array
declare -gA  file_tag_array
declare -A studio_file_regex
declare -A override
declare -A pornhub_regex
declare -a __shell_cmd=("")
declare -A title_replace_words
declare -A studio_match


declare -A __genre_list_array


while read -r line || [[ -n "${line}" ]]
do
    if [[ $line != "" ]]
    then
        mapfile  -t -d"=" -c1 __b_result_array <<< "${line}"

        __key=${__b_result_array[0]}
        __key=${__key// /_}
        __key=${__key,,}
        __key=${__key//+/}
        __key=${__key//\//_}
        
        __value=$(string.trim ${__b_result_array[1]})
          
        __genre_list_array["$__key"]="${__value}"

    fi
    
done <  "${__GENRE_MAP_FILE}"


## Colours and font styles
## Syntax: echo -e "${FOREGROUND_COLOUR}${BACKGROUND_COLOUR}${STYLE}Hello world!${RESET_ALL}"

# Escape sequence and resets
ESC_SEQ="\x1b["
RESET_ALL="${ESC_SEQ}0m"
RESET_BOLD="${ESC_SEQ}21m"
RESET_UL="${ESC_SEQ}24m"

# Foreground colours
FG_BLACK="${ESC_SEQ}30;"
FG_RED="${ESC_SEQ}31;"
FG_GREEN="${ESC_SEQ}32;"
FG_YELLOW="${ESC_SEQ}33;"
FG_BLUE="${ESC_SEQ}34;"
FG_MAGENTA="${ESC_SEQ}35;"
FG_CYAN="${ESC_SEQ}36;"
FG_WHITE="${ESC_SEQ}37;"
FG_BR_BLACK="${ESC_SEQ}90;"
FG_BR_RED="${ESC_SEQ}91;"
FG_BR_GREEN="${ESC_SEQ}92;"
FG_BR_YELLOW="${ESC_SEQ}93;"
FG_BR_BLUE="${ESC_SEQ}94;"
FG_BR_MAGENTA="${ESC_SEQ}95;"
FG_BR_CYAN="${ESC_SEQ}96;"
FG_BR_WHITE="${ESC_SEQ}97;"

# Background colours (optional)
BG_BLACK="40;"
BG_RED="41;"
BG_GREEN="42;"
BG_YELLOW="43;"
BG_BLUE="44;"
BG_MAGENTA="45;"
BG_CYAN="46;"
BG_WHITE="47;"

# Font styles
FS_REG="0m"
FS_BOLD="1m"
FS_UL="4m"
