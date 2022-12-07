package config

import (
	"time"
)

func NewConfig() *ConfigImpl {
	return &ConfigImpl{
		Port:                 "8080",
		CSVPath:              "data/entrance.csv",
		CORSDomains:          []string{"*"},
		CORSHeaders:          []string{"*"},
		CORSMethods:          []string{"GET"},
		CORSAllowCredentials: false,
		CORSMaxAge:           86400 * time.Second,
	}
}
