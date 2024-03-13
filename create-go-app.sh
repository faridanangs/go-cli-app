#!/usr/bin/bash
set -euo pipefail

cat <<EOF

        $|> $(date) <|$

EOF

if [ $# -eq 0 ]; then
        printf "package name: "
        read -r package

        if [ -z "$package" ]; then
                echo "package name should not be empty!"
                exit 1
        fi
else
        package=$1
fi

mapfile -d "/" packagePart <<< "$package"

dirName="${packagePart[-1]%?}"

if [ "$dirName" == "." ]; then
	# Initialize git
	printf "Initialize git [y/N]? "
	read -r git


	if [ -z "$git" ]; then
		git="y"
	else
		echo
	fi


	if [ ${git,,} == "y" ]; then
		git init -q
	fi

	# Initialize go project
	projectName=$(basename "$(pwd)")
	go mod init "$projectName" &>/dev/null

	echo "$projectName"

else
	echo "$dirName"
	echo "dirr"

fi
