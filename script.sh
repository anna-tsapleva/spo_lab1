#!/bin/bash
error_message="Usage: $0 [DIRECTORY] [DIRECTORY]..."
directories=""

if [[ "$#" -ge 1 ]] ; then
	for arg in "$@"
	do
		if ! [[ -d "$arg" ]] ; then
			echo "$error_message"
			exit 1
		fi
		directories+="$arg"
		directories+=$'\n'
	done
else
	directories="."
fi

result=$'name,size,type,last modified,length(for video)'
for directory in $directories
do
	files=$(ls -Rl "$directory" --block-size=MB | grep "^-")
	while read -r file; do
		nameAndExt=$(echo "$file" | awk -F " " '{out=""; for(i=9;i<=NF;i++){if (i == 9) {out=out""$i;} else {out=out" "$i;};}; print out}')
		name=$(echo "$nameAndExt" | awk -F "." '{out=""; if(NF > 1) {for(i=1;i<NF;i++){if (i == 1) {out=out""$i;} else {out=out"."$i;};}; print out;}else {print $0;};}')
		ext=$(echo "$nameAndExt" | awk -F "." '{if(NF > 1) {print $NF;} else {print "-";};}')
		size=$(echo "$file" | awk -F " " '{print $5}')
		lastModified=$(echo "$file" | awk -F " " '{print $7" "$6" "$8}')
		length=""
		if [[ "$ext" == "avi" ]] || [[ "$ext" == "mp4" ]] || [[ "$ext" == "mp3" ]]

		then
			length=$(mediainfo "$directory/$nameAndExt" --Output="General;%Duration/String%")
		fi

		resultForFile="$name,$size,$ext,$lastModified,$length"
		result+=$'\n'
		result+="$resultForFile"

	done <<< "$files"
done

echo "$result" > result.xls
