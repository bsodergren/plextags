
function print_usage()
{

	__genre_list_str=$(printf ",%s" "${__GENRE_LIST[@]}")
	__genre_list_str=${__genre_list_str:1}


	__usage="
Usage: $(basename "$0") [OPTIONS]

Options:
  -A. --aprove			Aprove changes
  -v, --verbose			turns off progress bar and displays actions
  -c, --changes			Shows only changes, does not make them.
  -R, --refresh			Updates all data from the filename

  -t, --title <text>	Add title to specified file (use with -f)
  -g, --genre <text>	Set Genre of videos
${__genre_list_str}
  -s, --studio <text>	Studio (Collection) name
  -a, --actors <text>	Sets actor list.
  -k, --keyword <text> path of file.

  -e, --empty-tag <tags>	Remove tags, comma separated, or keyword ALL
  -o, --set-only <tags>		Set only the Genre or Studio.
<tags> can be
title, studio, genre, actor, ALL

  -f, --file			Work on only this file
  -n, --fileNo			Number of file in list
  -y, --favorite		add video to favorites.

  -m, --max <n>			Max number of items to loop through
  -l, --max-depth <n>	set max depth for find to go through.
  -p, --showTags		Show tags on file
  -O, --outfile			set a new output filename
  -i, --ignore			ignore a file by number
  -r, --rename			renames files
  -E, --missing			find files with missing tags
  -d, --debug			Debug stuff
  -u, --update			update cache files
  -h, --help			help
  -P, --prefix			prefix for rename
  -M, --move			Move files into studio channels
  -T, --transcode		Transcode file to mp4
  -S, --sort            Sorts files into folder based on Studio tag
  -Q, --quiet           Dont log anything maybe
"
	echo "$__usage"

}

params="'$@'"

for arg in "$@"
do
	shift
	case "$arg" in
        "--aprove") set -- "$@" "-A" ;;
        "--verbose") set -- "$@" "-v" ;;
        "--changes") set -- "$@" "-c" ;;
        "--refresh") set -- "$@" "-R" ;;
        "--sort") set -- "$@" "-S" ;;
        "--list") set == "$@" "-L" ;;
        
        "--title") set -- "$@" "-t" ;;
        "--genre") set -- "$@" "-g" ;;
        "--studio") set -- "$@" "-s" ;;
        "--actors") set -- "$@" "-a" ;;
        "--keyword") set -- "$@" "-k" ;;

        "--set-only") set -- "$@" "-o" ;;
        "--rename") set -- "$@" "-r" ;;
        "--move") set -- "$@" "-M" ;;
        "--showTags") set -- "$@" "-p" ;;

        "--update") set -- "$@" "-u" ;;
        "--file") set -- "$@" "-f" ;;
        "--fileNo") set -- "$@" "-n" ;;
        "--new-files") set -- "$@" "-N" ;;
        "--dir") set -- "$@" "-D" ;;
        "--empty-tag") set -- "$@" "-e" ;;

        "--favorites") set -- "$@" "-y" ;;
        "--missing") set -- "$@" "-E" ;;
        "--max") set -- "$@" "-m" ;;
        "--maxdepth") set -- "$@" "-l" ;;
        "--ignore") set -- "$@" "-i" ;;
        "--hashfile") set -- "$@" "-q" ;;

        "--outfile") set -- "$@" "-O";;
        "--debug") set -- "$@" "-d" ;;
        "--prefix") set -- "$@" "-P" ;;
        "--help") set -- "$@" "-h" ;;
        "--quiet") set -- "$@" "-Q" ;;
        "--transcode") set -- "$@" "-T" ;;
		*) set -- "$@" "$arg" ;;
	esac
done

# Parse short options
OPTIND=1

while getopts ":pAvct:g:u:s:a:k:e:o:f:m:i:dhn:D:O:rE:qNyP:SMTRQL" opt; do

	case "$opt" in
        "L") __LIST_NUM_FILES=1;;
		"A") __APROVE=1 ;;
		"v") __VERBOSE=1 ;;
		"c") __SHOW_CHANGES=1;;
		"R") __REFRESH=1;;
		"N")  #Only run in root directory
			[[ $(string.compare ${directory} ${__current_directory}) -eq 1 ]] && __ONLY_NEW=1 && CLi_OPTIONS["ONLY_NEW"]=1 ;;
 
		"E")
			__FIND_MISSING="$OPTARG"
            CLi_OPTIONS["MISSING"]=1 ;;



		"t") override["title"]="$OPTARG" ;;
		"g") override["genre"]="$OPTARG" ;;
		"s") override["studio"]="$OPTARG" ;;
		"a") override["artist"]="$OPTARG" ;;
        "k") override["keyword"]="$OPTARG" ;;

		"e") __REMOVE_TAGS=$OPTARG
			
				if [[ ! "${__tag_list[@]}" =~ "${__REMOVE_TAGS,,}" ]]
				then
					main.log " __REMOVE_TAGS" "${__REMOVE_TAGS}"
					if [[ ! "all" =~ "${__SETONLY,,}" ]]
					then
						print_usage >&2
						exit 1
					fi
				fi ;;
				
		"o") __SETONLY=$OPTARG

#&& "all" =~ "${__SETONLY,,}"            
				if [[ ! "${__tag_list[@]}" =~ "${__SETONLY,,}" ]]
				then
                 echo -e "155 set only tag ${__tag_list[0]}"
					print_usage >&2
					exit 1
				fi ;;
		"p") __SHOW_TAGS=1 ;;
        "S") __SORT=1;;
         "Q") __QUIET=1;;


		"f") __FILELIST=$OPTARG ;;
        "u") __UPDATE=$OPTARG ;;
		"y") __FAVORITE=1;;
		"n") __FILE_NUMBER=$OPTARG ;;
		"m") __MAX_RESULTS=$OPTARG ;;
		"l") __MAX_DEPTH=$OPTARG ;;
		"D") __CHANGEDIR="/$OPTARG" ;;
		"O") __OUTFILENAME="$OPTARG" ;;
		"i") __IGNORE_NUMBER=$OPTARG ;;
		"d") __DEBUG=1 ;;
		"q") __MAKE_HASHFILE=1 ;;
		"r") __RENAME_FILES=1
                    CLi_OPTIONS["RENAME"]=1;;
		"M")
            [[ $in_directory == "pornhub" ]] && __MOVE_FILES=1 && CLi_OPTIONS["MOVE_FILES"]=1 ;;
		"P") __PREFIX=$OPTARG;;
		"T") __TRANSCODE=1
                    CLi_OPTIONS["TRANSCODE"]=1;;
		"h") print_usage >&2
			exit 1
			;;
		*)	print_usage >&2
			exit 1
			;;
	esac
done

shift $((OPTIND - 1))

shopt -s nocasematch