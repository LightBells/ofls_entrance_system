package interfaces

type Context interface {
	Header(string, string)
	GetHeader(string) string
	String(int, string, ...interface{})
	Param(string) string
	Bind(interface{}) error
	Status(int)
	JSON(int, interface{})
}
