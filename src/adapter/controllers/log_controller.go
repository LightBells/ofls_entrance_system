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
			LogSlice []Log `json:"logs"`
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
		LogSlice: jsonLogs,
	}

	c.JSON(200, response)
}

func (lc *LogController) GetByMonth(c interfaces.Context) {
	if c.GetHeader("Accept") == "text/csv" {
		lc.getByMonthReturnInCsv(c)
	} else {
		lc.getByMonthReturnInJson(c)
	}
}

func (lc *LogController) getByMonthReturnInCsv(c interfaces.Context) {
	month := c.Param("month")
	logs, err := lc.Interactor.GetByMonthInCsv(month)
	if err != nil {
		c.JSON(500, NewError(500, err.Error()))
		return
	}

	c.Header("Content-Type", "text/csv")
	c.Header("Content-Disposition", "attachment; filename="+month+"logs.csv")
	c.String(200, logs)
}

func (lc *LogController) getByMonthReturnInJson(c interfaces.Context) {
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

	month := c.Param("month")
	logs, err := lc.Interactor.GetByMonth(month)
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

	c.Header("Content-Type", "application/json")
	c.JSON(200, response)
}
