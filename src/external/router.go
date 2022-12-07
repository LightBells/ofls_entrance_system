package external

import (
	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"

	"github.com/LightBells/ofls_entrance_system/src/adapter/controllers"
	"github.com/LightBells/ofls_entrance_system/src/external/config"
	"github.com/LightBells/ofls_entrance_system/src/external/csv"
)

func Run(path string) {
	router := gin.Default()

	config, err := config.ReadYaml(path)
	if err != nil {
		panic(err)
	}

	router.Use(cors.New(cors.Config{
		AllowOrigins:     config.GetCORSDomains(),
		AllowMethods:     config.GetCORSMethods(),
		AllowHeaders:     config.GetCORSHeaders(),
		AllowCredentials: config.GetCORSAllowCredentials(),
		MaxAge:           config.GetCORSMaxAge(),
	}))

	csvHandler := external.NewCSVHandler(config.GetCSVPath())
	logController := controllers.NewLogController(csvHandler)

	router.GET("/v1/logs", func(c *gin.Context) {
		logController.Get(c)
	})

	router.Run(":" + config.GetPort())
}
