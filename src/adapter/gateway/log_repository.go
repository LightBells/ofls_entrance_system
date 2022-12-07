package gateway

import (
	"github.com/LightBells/ofls_entrance_system/src/adapter/interfaces"
	"github.com/LightBells/ofls_entrance_system/src/domain"
)

type (
	LogRepository struct {
		csvHandler interfaces.CSVHandler
	}

	Log struct {
		ID            string `csv:"id"`
		date          string `csv:"date"`
		entry_time    string `csv:"entry_time"`
		exit_time     string `csv:"exit_time"`
		purpose       int16  `csv:"purpose"`
		satisfication int16  `csv:"satisfication"`
	}
)

func (r *LogRepository) FindAll() (domain.LogSlice, error) {
	logs := domain.LogSlice{}
	if err := r.csvHandler.ReadCSV(&logs); err != nil {
		return nil, err
	}
	return logs, nil
}

func NewLogRepository(handler interfaces.CSVHandler) *LogRepository {
	return &LogRepository{
		csvHandler: handler,
	}
}
