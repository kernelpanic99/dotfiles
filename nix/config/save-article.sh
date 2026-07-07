#!/bin/sh
destination="${HOME}/Documents/Notes/Inbox/"

feed=$(echo "$1" | sed 's%/%-%g') # substitute / by -
date=$(echo "$2" | sed 's%/%-%g') 
title=$(echo "$3" | sed 's%/%-%g')
dir="${destination}/${feed}"
path="${dir}/${date}-${title}.md"

mkdir -p "${dir}"

cat > "${path}"
