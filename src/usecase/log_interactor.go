package usecase

import (
	"sort"

	"github.com/LightBells/ofls_entrance_system/src/domain"
	"github.com/LightBells/ofls_entrance_system/src/usecase/interfaces"
)

type LogInteractor struct {
	LogRepository interfaces.LogRepository
}

func (i *LogInteractor) Get() (domain.LogSlice, error) {
	logs, err := i.LogRepository.FindAll()
	if err != nil {
		return domain.LogSlice{}, err
	}

	// 降順に返す
	sort.Slice(logs, func(i, j int) bool {
		return logs[i].After(&logs[j])
	})

	return logs, nil
}

func (i *LogInteractor) GetByMonth(month string) (domain.LogSlice, error) {
	logs, err := i.LogRepository.FindAll()
	if err != nil {
		return domain.LogSlice{}, err
	}

	logs = logs.Where(func(log domain.Log) bool {
		return log.EnterAt().Format("200601") == month
	})

	return logs, nil
}

func (i *LogInteractor) GetByMonthInCsv(month string) (string, error) {
	logs, err := i.GetByMonth(month)
	if err != nil {
		return "", err
	}

	csvString, err := i.LogRepository.RepresentInCsv(logs)
	if err != nil {
		return "", err
	}

	return csvString, nil
}
