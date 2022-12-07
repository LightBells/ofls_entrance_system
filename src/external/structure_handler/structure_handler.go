package structure_handler

import (
	"os"
)

func CreateDirIfNotExist(path string) error {
	exists := isExist(path)
	if exists {
		return nil
	}
	err := os.MkdirAll(path, os.ModePerm)
	return err
}

func isExist(path string) bool {
	_, err := os.Stat(path)
	return !os.IsNotExist(err)
}
