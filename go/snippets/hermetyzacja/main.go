package main

import (
	"fmt"
	"insidestruct"
	"outsidestruct"
)

var o outsidestruct.Outside
var i insidestruct.Inside

// func RemoveI(i *insidestruct.Inside) {
// 	i.s.words = ""
// }

func RemoveO(o *outsidestruct.Outside) {
	(*o) = ""
}

func main() {
	o.Add()
	i.Add()
	i.Derp()
	fmt.Println(o)
	fmt.Println(i)
	RemoveO(&o)
	fmt.Println(o)
}
