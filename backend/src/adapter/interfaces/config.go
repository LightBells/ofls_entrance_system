package interfaces

type Config interface {
	GetAdminPassword() string
	GetJWTRealm() string
}
