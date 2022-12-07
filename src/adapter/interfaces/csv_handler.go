package interfaces

import (
	"github.com/LightBells/ofls_entrance_system/src/domain"
)

type CSVHandler interface {
	ReadCSV(*domain.Logs) error
}
