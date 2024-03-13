cat <<EOF
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