package config

import (
	"fmt"
	"io/ioutil"

	"gopkg.in/yaml.v2"
)

func ReadYaml(path string) (Config, error) {
	bytes, err := ioutil.ReadFile(path)
	if err != nil {
		return nil, err
	}

	data, err := ReadOnStruct(bytes)
	if err != nil {
		return nil, err
	}

	fmt.Println("Loaded config from", path)
	fmt.Println("Config:")
	data.Print()
	fmt.Println("=========================================")
	fmt.Println("")

	return data, nil
}

func ReadOnStruct(fileBuffer []byte) (Config, error) {
	data := ConfigImpl{}

	err := yaml.Unmarshal(fileBuffer, &data)

	if err != nil {
		return nil, err
	}
	return &data, nil
}
