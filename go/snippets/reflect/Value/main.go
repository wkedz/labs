package main

import (
	"fmt"
	"reflect"
)

func main() {
	s := []string{"a", "b", "c"}
	sv := reflect.ValueOf(s)
	// sv jest typu reflect.Value
	s2 := sv.Interface().([]string) // s2 jest typu []string
	fmt.Println(s)
	fmt.Println(s2)
}
