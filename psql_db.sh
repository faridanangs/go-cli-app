cat <<EOF
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