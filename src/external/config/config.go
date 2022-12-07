package config

import (
	"time"
)

type Config interface {
	GetPort() string

	GetCSVPath() string

	GetCORSDomains() []string
	GetCORSHeaders() []string
	GetCORSMethods() []string
	GetCORSAllowCredentials() bool
	GetCORSMaxAge() time.Duration
	Print()
}
