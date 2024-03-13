cat <<EOF
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