package external

import (
	"bytes"
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

func (h *CSVHandler) ReadCSV(logs *domain.LogSlice) error {
	file, err := os.Open(h.path)
	if err != nil {
		return err
	}
	defer file.Close()

	reader := csv.NewReader(file)

	// ヘッダーを読み飛ばす
	_, err = reader.Read()
	if err == io.EOF {
		return err
	}

	for {
		record, err := reader.Read()
		if err == io.EOF {
			break
		}
		if err != nil {
			return err
		}

		purpose := -1
		if record[4] != "" {
			purpose, err = strconv.Atoi(record[4])
			if err != nil {
				return err
			}
		}

		satisfication := -1
		if record[5] != "" {
			satisfication, err = strconv.Atoi(record[5])
			if err != nil {
				return err
			}
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

func (h *CSVHandler) WriteCSV(logs *domain.LogSlice, path string) error {
	file, err := os.Create(path)
	if err != nil {
		return err
	}
	defer file.Close()

	writer := csv.NewWriter(file)
	writer.Write([]string{"ID", "Date", "Entry_time", "Exit_time", "Purpose", "Satisfication"})
	for _, log := range *logs {
		writer.Write([]string{log.ID, log.Date, log.Entry_time, log.Exit_time, strconv.Itoa(log.Purpose), strconv.Itoa(log.Satisfication)})
	}
	writer.Flush()
	return nil
}

func (h *CSVHandler) ConvertToCSVString(logs *domain.LogSlice) (string, error) {
	buf := new(bytes.Buffer)
	writer := csv.NewWriter(buf)

	writer.Write([]string{"ID", "Date", "Entry_time", "Exit_time", "Purpose", "Satisfication"})
	for _, log := range *logs {
		purpose := strconv.Itoa(log.Purpose)
		if purpose == "-1" {
			purpose = ""
		}

		satisfication := strconv.Itoa(log.Satisfication)
		if satisfication == "-1" {
			satisfication = ""
		}

		writer.Write([]string{log.ID, log.Date, log.Entry_time, log.Exit_time, purpose, satisfication})
	}
	writer.Flush()
	return buf.String(), nil
}
