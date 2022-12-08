package config

import (
	"time"
)

type Config interface {
	GetPort() string

	GetCSVPath() string
	GetStaticPath() string
	GetSecretPath() string
	GetJWTRealm() string
	GetAdminPassword() string

	GetCORSDomains() []string
	GetCORSHeaders() []string
	GetCORSMethods() []string
	GetCORSAllowCredentials() bool
	GetCORSMaxAge() time.Duration
	Print()
}
