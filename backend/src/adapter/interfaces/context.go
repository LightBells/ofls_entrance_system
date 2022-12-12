package interfaces

type Context interface {
	Header(string, string)
	ShouldBindJSON(interface{}) error
	GetHeader(string) string
	String(int, string, ...interface{})
	Param(string) string
	PostForm(string) string
	Bind(interface{}) error
	Status(int)
	JSON(int, interface{})
}
