package main

import (
	"bytes"
	"fmt"
	"io"
)

type Inte struct {
	io.Writer
}

type Inte2 struct {
	io.Writer
}

func (i *Inte) Write([]byte) (int, error) {
	return 0, nil
}

func main() {
	var i Inte
	fmt.Printf("i: %v\n", i)
	b := make([]byte, 4)
	n, _ := i.Write(b)
	fmt.Printf("n: %v\n", n)
	i2 := Inte2{
		Writer: new(bytes.Buffer),
	}
	fmt.Printf("i2: %v\n", i2)
}
