package csv

import (
	"encoding/csv"
	"io"
	"os"
	"strconv"

	"github.com/LightBells/ofls_entrance_system/src/domain"
)

type CSVHandler struct {
	path string
}

func NewCSVHandler(path string) *CSVHandler {
	return &CSVHandler{path}
}

func (h *CSVHandler) ReadCSV(logs *domain.Logs) error {
	file, err := os.Open(h.path)
	if err != nil {
		return err
	}
	defer file.Close()

	reader := csv.NewReader(file)
	for {
		record, err := reader.Read()
		if err == io.EOF {
			break
		}
		if err != nil {
			return err
		}
		purpose, err := strconv.Atoi(record[4])
		if err != nil {
			return err
		}

		satisfication, err := strconv.Atoi(record[5])
		if err != nil {
			return err
		}

		log := domain.Log{
			ID:            record[0],
			Date:          record[1],
			Entry_time:    record[2],
			Exit_time:     record[3],
			Purpose:       purpose,
			Satisfication: satisfication,
		}

		*logs = append(*logs, log)
	}
	return nil
}
