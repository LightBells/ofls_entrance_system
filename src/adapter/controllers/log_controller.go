package controllers

import (
	"github.com/LightBells/ofls_entrance_system/src/adapter/gateway"
	"github.com/LightBells/ofls_entrance_system/src/adapter/interfaces"
	"github.com/LightBells/ofls_entrance_system/src/usecase"
)

type LogController struct {
	Interactor usecase.LogInteractor
}

func NewLogController(handler interfaces.CSVHandler) *LogController {
	return &LogController{
		Interactor: usecase.LogInteractor{
			LogRepository: gateway.NewLogRepository(handler),
		},
	}
}

func (lc *LogController) Get(c interfaces.Context) {
	type (
		Log struct {
			ID            string `json:"id"`
			Date          string `json:"date"`
			Entry_time    string `json:"entry_time"`
			Exit_time     string `json:"exit_time"`
			Purpose       int    `json:"purpose"`
			Satisfication int    `json:"satisfication"`
		}
		Response struct {
			Logs []Log `json:"logs"`
		}
	)

	logs, err := lc.Interactor.Get()
	if err != nil {
		c.JSON(500, NewError(500, err.Error()))
		return
	}

	jsonLogs := []Log{}
	for _, log := range logs {
		jsonLogs = append(jsonLogs, Log{
			ID:            log.ID,
			Date:          log.Date,
			Entry_time:    log.Entry_time,
			Exit_time:     log.Exit_time,
			Purpose:       log.Purpose,
			Satisfication: log.Satisfication,
		})
	}

	response := Response{
		Logs: jsonLogs,
	}

	c.JSON(200, response)
}
