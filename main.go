package main

import (
	"github.com/LightBells/ofls_entrance_system/config"
	"github.com/LightBells/ofls_entrance_system/src/external"
)

func main() {
	config := config.NewConfig()

	external.Run(config)
}
