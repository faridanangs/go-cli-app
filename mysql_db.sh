cat <<EOF
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

  dsn := fmt.Sprintf("%s:%s@tcp(%s:%s)/%s?charset=utf8mb4&parseTime=True&loc=Local",
    dbConfig.user,
    dbConfig.pass,
    dbConfig.host,
    dbConfig.port,
    dbConfig.name,
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