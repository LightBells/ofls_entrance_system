package config

import (
	"fmt"
	"time"
)

type ConfigImpl struct {
	Port                 string   `yaml:"port"`
	CSVPath              string   `yaml:"csv_path"`
	CORSDomains          []string `yaml:"cors_domains"`
	CORSHeaders          []string `yaml:"cors_headers"`
	CORSMethods          []string `yaml:"cors_methods"`
	CORSAllowCredentials bool     `yaml:"cors_allow_credentials"`
	CORSMaxAge           int      `yaml:"cors_max_age"`
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
	return time.Duration(c.CORSMaxAge) * time.Second
}

func (data *ConfigImpl) Print() {
	fmt.Println("Port:", data.GetPort())
	fmt.Println("CSVPath:", data.GetCSVPath())
	fmt.Println("CORSDomains:", data.GetCORSDomains())
	fmt.Println("CORSHeaders:", data.GetCORSHeaders())
	fmt.Println("CORSMethods:", data.GetCORSMethods())
	fmt.Println("CORSAllowCredentials:", data.GetCORSAllowCredentials())
	fmt.Println("CORSMaxAge:", data.GetCORSMaxAge())
}
