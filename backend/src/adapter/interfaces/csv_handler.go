package interfaces

import (
	"github.com/LightBells/ofls_entrance_system/src/domain"
)

type CSVHandler interface {
	ReadCSV(*domain.LogSlice) error
	WriteCSV(*domain.LogSlice, string) error
	ConvertToCSVString(*domain.LogSlice) (string, error)
}
