package external

import (
	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"

	"github.com/LightBells/ofls_entrance_system/src/adapter/controllers"
	"github.com/LightBells/ofls_entrance_system/src/external/csv"
	"github.com/LightBells/ofls_entrance_system/src/external/interfaces"
)

func Run(config interfaces.Config) {
	router := gin.Default()

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
