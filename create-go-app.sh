#!/usr/bin/bash
set -euo pipefail


cat <<EOF

$(date)
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

# Initialize git
printf "Initialize git [y/N]? "
read -r git

if [ -z "$git" ]; then
        git="y"
fi

deps=("github.com/joho/godotenv")

# choise framwork
cat <<EOF
Choose your go framwork
1. Fiber
2. Gin
n. none
EOF
printf "[1/2/n] ~ [default=1]? "
read -n1 -r framwork

if [ -z "$framwork" ]; then
        framwork="1"
fi

case $framwork in
"1")
        deps+=("github.com/gofiber/fiber/v2")
        echo
;;
"2")
        deps+=("github.com/gin-gonic/gin")
        echo
;;
"n")
        echo
;;
*)
        deps+=("github.com/gofiber/fiber/v2")
        echo
;;
esac

# choise orm
cat <<EOF
Choose your orm library
1. gorm
n. none
EOF
printf "[1/n] ~ [default=1]? "
read -n1 -r orm

if [ -z "$orm" ]; then
        orm="1"
fi

case $orm in
"1")
        deps+=("gorm.io/gorm")
        echo
;;
"n")
        echo
;;
*)
        deps+=("gorm.io/gorm")
        echo
;;
esac

# choise database
cat <<EOF
Choose your database
1. postgreSQL
2. mySQL
n. none
EOF
printf "[1/2] ~ [default=1]? "
read -n1 -r database

if [ -z "$database" ]; then
        database="1"
fi

case $database in
"1")
        deps+=("gorm.io/driver/postgres")
        echo
;;
"2")
        deps+=("gorm.io/driver/mysql")
        echo
;;
"n")
        echo
;;
*)
        deps+=("gorm.io/driver/postgres")
        echo
;;
esac

# Install jwt
printf "Install jwt library (y/N)? "
read -r jwt
if [[ ${jwt,,} == "y" && -n "$jwt" ]]; then
        deps+=("github.com/dgrijalva/jwt-go")
else 
        echo "No"
fi

# Instaall validator
printf "Install validator library (y/N)? "
read -r validator
if [[ ${validator,,} == "y" && -n "$validator" ]]; then
        deps+=("github.com/go-playground/validator/v10")
        echo
else 
        echo "N0"
fi



if [ "$dirName" == "." ]; then
	if [ ${git,,} == "y" ]; then
		git init -q
	fi

        # Initialize folders
        source folder.sh

	# Initialize go oroject
	projectName=$(basename "$(pwd)")
	go mod init "$projectName" &>/dev/null
        echo "Installing dependencies...."
        go get -u ${deps[@]} &>/dev/null

        # install framwork
        if [[ " ${deps[@]} " =~ "github.com/gofiber/fiber/v2" ]]; then
                source fiber.sh > main.go
        elif [[ " ${deps[@]} " =~ "github.com/gin-gonic/gin" ]]; then
                source gin.sh > main.go
        fi

        # install db
        if [[ " ${deps[@]} " =~ "gorm.io/driver/postgres" ]]; then
                source  psql_db.sh > db/db.go

        elif [[ " ${deps[@]} " =~ "gorm.io/driver/mysql" ]]; then
                source  mysql_db.sh > db/db.go
        fi

        echo ".env" > .gitignore
        echo "APP_PORT=8000" > .env
        echo "DB_USER=user" >> .env
        echo "DB_PASSWORD=password" >> .env
        echo "DB_NAME=default" >> .env
        echo "DB_HOST=localhost" >> .env
        echo "DB_PORT=0000" >> .env

        echo "Installing finised"
        
else
        # Initialize folders
	mkdir "$dirName"
        cd "$dirName"
        source ../folder.sh

        if [ ${git,,} == "y" ]; then
                git init -q
        fi

        # Initialize go oroject
        projectName=$(basename "$(pwd)")
        go mod init "$projectName" &>/dev/null
        echo "Installing dependencies...."
        go get -u ${deps[@]} &>/dev/null

        # Install framwork
        if [[ " ${deps[@]} " =~ "github.com/gofiber/fiber/v2" ]]; then
                source ../fiber.sh > main.go

        elif [[ " ${deps[@]} " =~ "github.com/gin-gonic/gin" ]]; then
                source ../gin.sh > main.go
        fi

        # install db
        if [[ " ${deps[@]} " =~ "gorm.io/driver/postgres" ]]; then
                source ../psql_db.sh > db/db.go

        elif [[ " ${deps[@]} " =~ "gorm.io/driver/mysql" ]]; then
                source ../mysql_db.sh > db/db.go
        fi

        echo ".env" > .gitignore
        echo "APP_PORT=8000" > .env
        echo "DB_USER=user" >> .env
        echo "DB_PASSWORD=password" >> .env
        echo "DB_NAME=default" >> .env
        echo "DB_HOST=localhost" >> .env
        echo "DB_PORT=0000" >> .env

        echo "Installing finised"

fi