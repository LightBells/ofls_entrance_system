package external

import (
	"github.com/LightBells/ofls_entrance_system/src/external/config"
	"github.com/LightBells/ofls_entrance_system/src/external/structure_handler"
)

func Initialize(path string) {
	config, err := config.ReadYaml(path)
	if err != nil {
		panic(err)
	}

	structure_handler.CreateDirIfNotExist(config.GetStaticPath())

	Run(config)
}
