package usecase

import (
	"github.com/LightBells/ofls_entrance_system/src/domain"
	"github.com/LightBells/ofls_entrance_system/src/usecase/interfaces"
)

type LogInteractor struct {
	LogRepository interfaces.LogRepository
}

func (i *LogInteractor) Get() (domain.Logs, error) {
	return i.LogRepository.FindAll()
}
