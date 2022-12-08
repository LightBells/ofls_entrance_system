package external

import (
	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	"github.com/ken109/gin-jwt"

	"github.com/LightBells/ofls_entrance_system/src/adapter/controllers"
	"github.com/LightBells/ofls_entrance_system/src/external/config"
	"github.com/LightBells/ofls_entrance_system/src/external/csv"
)

func Run(config config.Config) {
	err := jwtInit(config)
	if err != nil {
		panic(err)
	}
	router := gin.Default()
	router.Use(CorsSettings(config))
	v1 := router.Group("/v1")

	authController := controllers.NewAuthController()
	v1.POST("/login", func(c *gin.Context) {
		authController.Login(c, config)
	})
	v1.POST("/refresh", func(c *gin.Context) {
		authController.Refresh(c, config)
	})

	logs := v1.Group("/logs")
	logs.Use(jwt.MustVerify(config.GetJWTRealm()))

	csvHandler := external.NewCSVHandler(config.GetCSVPath())
	logController := controllers.NewLogController(csvHandler)

	router.Static("/statics", "./statics")

	logs.GET("/", func(c *gin.Context) {
		logController.Get(c)
	})
	logs.GET("/monthly/:month", func(c *gin.Context) {
		logController.GetByMonth(c)
	})
	logs.GET("/id/:id", func(c *gin.Context) {
		logController.GetById(c)
	})
	router.Run(":" + config.GetPort())
}

func jwtInit(config config.Config) error {
	err := jwt.SetUp(jwt.Option{
		Realm:            config.GetJWTRealm(),
		SigningAlgorithm: jwt.RS256,
		PrivKeyFile:      config.GetSecretPath(),
	})
	if err != nil {
		return err
	}
	return nil
}

func CorsSettings(config config.Config) gin.HandlerFunc {
	return cors.New(cors.Config{
		AllowOrigins:     config.GetCORSDomains(),
		AllowMethods:     config.GetCORSMethods(),
		AllowHeaders:     config.GetCORSHeaders(),
		AllowCredentials: config.GetCORSAllowCredentials(),
		MaxAge:           config.GetCORSMaxAge(),
	})
}
