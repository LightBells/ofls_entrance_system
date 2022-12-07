package main

import (
	"github.com/LightBells/ofls_entrance_system/src/external"
)

func main() {
	external.Router.Run(":8080")
}
