package main

import (
	"fmt"
	"reflect"
)

type Foo struct{}

func main() {
	var x int
	xt := reflect.TypeOf(x)
	fmt.Println(xt.Name())
	fmt.Println(xt.Kind())
	f := Foo{}
	ft := reflect.TypeOf(f)
	fmt.Println(ft.Name())
	fmt.Println(ft.Kind())
	xpt := reflect.TypeOf(&x)
	fmt.Println(xpt.Name())
	fmt.Println(xpt.Kind())

	var xx int
	xxpt := reflect.TypeOf(&xx)
	fmt.Println(xpt.Name())
	// Zwraca pusty łańcuch
	fmt.Println(xxpt.Kind())
	// Zwraca reflect.Ptr
	fmt.Println(xxpt.Elem().Name()) // Zwraca "int"
	fmt.Println(xxpt.Elem().Kind()) // Zwraca reflect.Int
	// Zwraca "Foo"
	// Zwraca pusty łańcuch
}
