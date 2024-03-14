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