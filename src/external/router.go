package external

import (
	"github.com/gin-gonic/gin"

	"github.com/LightBells/ofls_entrance_system/src/adapter/controllers"
	"github.com/LightBells/ofls_entrance_system/src/external/csv"
)

var Router *gin.Engine

func init() {
	router := gin.Default()
	csvHandler := csv.NewCSVHandler("data/entrance.csv")

	logController := controllers.NewLogController(csvHandler)

	router.GET("/logs", func(c *gin.Context) {
		logController.Get(c)
	})

	Router = router
}
