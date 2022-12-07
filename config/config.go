package config

import (
	"time"
)

type ConfigImpl struct {
	Port                 string
	CSVPath              string
	CORSDomains          []string
	CORSHeaders          []string
	CORSMethods          []string
	CORSAllowCredentials bool
	CORSMaxAge           time.Duration
}

func (c *ConfigImpl) GetPort() string {
	return c.Port
}

func (c *ConfigImpl) GetCSVPath() string {
	return c.CSVPath
}

func (c *ConfigImpl) GetCORSDomains() []string {
	return c.CORSDomains
}

func (c *ConfigImpl) GetCORSHeaders() []string {
	return c.CORSHeaders
}

func (c *ConfigImpl) GetCORSMethods() []string {
	return c.CORSMethods
}

func (c *ConfigImpl) GetCORSAllowCredentials() bool {
	return c.CORSAllowCredentials
}

func (c *ConfigImpl) GetCORSMaxAge() time.Duration {
	return c.CORSMaxAge
}
