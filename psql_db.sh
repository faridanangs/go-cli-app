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
	dbConfig := struct {
		host,
		port,
		user,
		pass,
		name string
	}{
		host: os.Getenv("DB_HOST"),
		port: os.Getenv("DB_PORT"),
		user: os.Getenv("DB_USER"),
		pass: os.Getenv("DB_PASSWORD"),
		name: os.Getenv("DB_NAME"),
	}

	dsn := fmt.Sprintf("host=%s, port=%s, dbname=%s, password=%s, user=%s, sslmode=disable, TimeZone=Asia/Jakarta",
		dbConfig.host, dbConfig.port, dbConfig.name, dbConfig.pass, dbConfig.user,
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