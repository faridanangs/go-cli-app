#!/usr/bin/bash
set -euo pipefail


cat <<EOF

( $(date) )

EOF

if [ $# -eq 0 ]; then
printf "| Nama Package : "
        read -r package
        echo

        if [ -z "$package" ]; then
                echo "nama package tidak boleh kosong!"
                exit 1
        fi
else
        package=$1
fi

mapfile -d "/" packagePart <<< "$package"

dirName="${packagePart[-1]%?}"

# Initialize git
printf "Inisialisasi git [y/N]? "
read -r git

if [ -z "$git" ]; then
        git="y"
fi

deps=("github.com/joho/godotenv")

# choise framwork
cat <<EOF
-------------------------
| pilih framwork golang |
-------------------------
1. Fiber
2. Gin
n. none

EOF
printf "default=1 : "
read -r framwork

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
----------------------------
| pilih library orm golang |
----------------------------
1. gorm
n. none

EOF
printf "default=1 : "
read -r orm

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
------------------
| pilih database |
------------------
1. postgreSQL
2. mySQL
n. none

EOF
printf "default=1 : "
read -r database

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
printf "Install library jwt (y/N)? "
read -r jwt
if [[ ${jwt,,} == "y" && -n "$jwt" ]]; then
        deps+=("github.com/dgrijalva/jwt-go")
        echo
else 
        echo "NO"
fi

# Instaall validator
printf "Install library validator (y/N)? "
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
    mkdir helpers
    mkdir db
    mkdir middleware
    mkdir services
    mkdir repositoris
    mkdir models
    mkdir controllers
    mkdir routers
    mkdir libs
    mkdir test

	# Initialize go oroject
	projectName=$(basename "$(pwd)")
	go mod init "$projectName" &>/dev/null
cat <<EOF

---------------------------------
Sedang menginstall dependensi....
---------------------------------

EOF
        go get -u ${deps[@]} &>/dev/null

        # install framwork
if [[ " ${deps[@]} " =~ "github.com/gofiber/fiber/v2" ]]; then
cat <<EOF >main.go
package main

import(
    "github.com/gofiber/fiber/v2"
    _"github.com/joho/godotenv/autoload"
    "os"
)

func main(){
    app := fiber.New()
    port := os.Getenv("APP_PORT")

    app.Get("/", func(c *fiber.Ctx) error {
        return c.SendString("Hello World!")
    })

    app.Listen(":"+port)
}
EOF


elif [[ " ${deps[@]} " =~ "github.com/gin-gonic/gin" ]]; then
cat <<EOF >main.go
package main

import (
    "net/http"
    _"github.com/joho/godotenv/autoload"
    "os"
    "github.com/gin-gonic/gin"
)

func main() {
  r := gin.Default()
  port := os.Getenv("APP_PORT")

  r.GET("/", func(c *gin.Context) {
    c.JSON(http.StatusOK, gin.H{
      "message": "ok",
    })
  })

  r.Run(":"+port)

}
EOF

fi

        # install db
if [[ " ${deps[@]} " =~ "gorm.io/driver/postgres" ]]; then
cat <<EOF >db/db.go
package db

import (
	"fmt"
	"os"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

func ConnectDB() *gorm.DB {
	defer func() {
		if err := recover(); err != nil {
			fmt.Println(err.Error())
		}
	}()

	dsn := fmt.Sprintf("host=%s, port=%s, dbname=%s, password=%s, user=%s, sslmode=disable, TimeZone=Asia/Jakarta",
    	os.Getenv("DB_HOST"),
    	os.Getenv("DB_PORT"),
    	os.Getenv("DB_NAME"),
    	os.Getenv("DB_PASSWORD"),
		os.Getenv("DB_USER"),
	)

	db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{
		Logger:                 logger.Default.LogMode(logger.Info),
		SkipDefaultTransaction: true,
	})
	if err != nil {
		panic(err)
	}

	return db
}
EOF

elif [[ " ${deps[@]} " =~ "gorm.io/driver/mysql" ]]; then
cat <<EOF >db/db.go
package db

import (
  "gorm.io/driver/mysql"
  "gorm.io/gorm"
  "gorm.io/gorm/logger"
  "fmt"
  "os"
)

func ConnectDB() *gorm.DB {
	defer func() {
		if err := recover(); err != nil {
			fmt.Println(err.Error())
		}
	}()


  dsn := fmt.Sprintf("%s:%s@tcp(%s:%s)/%s?charset=utf8mb4&parseTime=True&loc=Local",
    os.Getenv("DB_USER"),
    os.Getenv("DB_PASSWORD"),
    os.Getenv("DB_HOST"),
    os.Getenv("DB_PORT"),
    os.Getenv("DB_NAME"),
  )

  db, err := gorm.Open(mysql.Open(dsn), &gorm.Config{
    Logger: logger.Default.LogMode(logger.Info),
    SkipDefaultTransaction: true,
  })

  if err!= nil {
    panic(err)
  }

  return db
}

EOF
fi

        echo ".env" > .gitignore
        echo "APP_PORT=8000" > .env
        echo "DB_USER=user" >> .env
        echo "DB_PASSWORD=password" >> .env
        echo "DB_NAME=default" >> .env
        echo "DB_HOST=localhost" >> .env
        echo "DB_PORT=0000" >> .env

cat <<EOF
---------------------------------
✓ Penginstallan selesai
---------------------------------

EOF
        
else
        # Initialize folders
	    mkdir "$dirName"
        cd "$dirName"
        mkdir helpers
        mkdir db
        mkdir middleware
        mkdir services
        mkdir repositoris
        mkdir models
        mkdir controllers
        mkdir routers
        mkdir libs
        mkdir test

        if [ ${git,,} == "y" ]; then
                git init -q
        fi

        # Initialize go oroject
        projectName=$(basename "$(pwd)")
        go mod init "$projectName" &>/dev/null
cat <<EOF

---------------------------------
Sedang menginstall dependensi....
---------------------------------

EOF
        go get -u ${deps[@]} &>/dev/null

        # Install framwork
if [[ " ${deps[@]} " =~ "github.com/gofiber/fiber/v2" ]]; then
cat <<EOF >main.go
package main

import(
    "github.com/gofiber/fiber/v2"
    _"github.com/joho/godotenv/autoload"
    "os"
)

func main(){
    app := fiber.New()
    port := os.Getenv("APP_PORT")

    app.Get("/", func(c *fiber.Ctx) error {
        return c.SendString("Hello World!")
    })

    app.Listen(":"+port)
}
EOF


elif [[ " ${deps[@]} " =~ "github.com/gin-gonic/gin" ]]; then
cat <<EOF >main.go
package main

import (
    "net/http"
    _"github.com/joho/godotenv/autoload"
    "os"
    "github.com/gin-gonic/gin"
)

func main() {
  r := gin.Default()
  port := os.Getenv("APP_PORT")

  r.GET("/", func(c *gin.Context) {
    c.JSON(http.StatusOK, gin.H{
      "message": "ok",
    })
  })

  r.Run(":"+port)

}
EOF

fi

        # install db
if [[ " ${deps[@]} " =~ "gorm.io/driver/postgres" ]]; then
cat <<EOF >db/db.go
package db

import (
	"fmt"
	"os"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

func ConnectDB() *gorm.DB {
	defer func() {
		if err := recover(); err != nil {
			fmt.Println(err.Error())
		}
	}()

	dsn := fmt.Sprintf("host=%s, port=%s, dbname=%s, password=%s, user=%s, sslmode=disable, TimeZone=Asia/Jakarta",
    	os.Getenv("DB_HOST"),
    	os.Getenv("DB_PORT"),
    	os.Getenv("DB_NAME"),
    	os.Getenv("DB_PASSWORD"),
		os.Getenv("DB_USER"),
	)

	db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{
		Logger:                 logger.Default.LogMode(logger.Info),
		SkipDefaultTransaction: true,
	})
	if err != nil {
		panic(err)
	}

	return db
}
EOF
elif [[ " ${deps[@]} " =~ "gorm.io/driver/mysql" ]]; then
cat <<EOF >db/db.go
package db

import (
  "gorm.io/driver/mysql"
  "gorm.io/gorm"
  "gorm.io/gorm/logger"
  "fmt"
  "os"
)

func ConnectDB() *gorm.DB {
	defer func() {
		if err := recover(); err != nil {
			fmt.Println(err.Error())
		}
	}()


  dsn := fmt.Sprintf("%s:%s@tcp(%s:%s)/%s?charset=utf8mb4&parseTime=True&loc=Local",
    os.Getenv("DB_USER"),
    os.Getenv("DB_PASSWORD"),
    os.Getenv("DB_HOST"),
    os.Getenv("DB_PORT"),
    os.Getenv("DB_NAME"),
  )

  db, err := gorm.Open(mysql.Open(dsn), &gorm.Config{
    Logger: logger.Default.LogMode(logger.Info),
    SkipDefaultTransaction: true,
  })

  if err!= nil {
    panic(err)
  }

  return db
}

EOF
fi

        echo ".env" > .gitignore
        echo "APP_PORT=8000" > .env
        echo "DB_USER=user" >> .env
        echo "DB_PASSWORD=password" >> .env
        echo "DB_NAME=default" >> .env
        echo "DB_HOST=localhost" >> .env
        echo "DB_PORT=0000" >> .env

cat <<EOF
---------------------------------
✓ Penginstallan selesai
---------------------------------

EOF
fi