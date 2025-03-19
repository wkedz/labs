package main

import (
	"fmt"
	// "to/jest/simple/simple1"
	// "to/jest/simple/simple2"

	"github.com/google/go-cmp/cmp"
)

func main() {
	simple1.Simple1()
	simple2.Simple2()
	fmt.Println(cmp.Diff("Hello World", "Hello Go"))
}
