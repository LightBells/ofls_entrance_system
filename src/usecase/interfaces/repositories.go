package interfaces

import "github.com/LightBells/ofls_entrance_system/src/domain"

type LogRepository interface {
	FindAll() (domain.LogSlice, error)
	RepresentInCsv(domain.LogSlice) (string, error)
}
