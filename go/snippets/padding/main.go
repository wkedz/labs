package main

import (
	"fmt"
	"unsafe"
)

func main() {
	var a struct {
		One uint64 //8
		Two uint32 //4
	}
	var s struct {
		One   uint64 //8
		Two   uint32 //4
		Three uint16 //2
		// _ [2]byte //2
	}

	var ss struct {
		One   uint64
		Two   uint32
		Three uint16
		_     [2]byte
	}

	// We got 16 because struct definitions are padded to the next machine word size (64bits)
	fmt.Printf("want: %d, got: %d\n", 8+4+2, unsafe.Sizeof(s))

	fmt.Printf("want: %d, got: %d\n", 8+4, unsafe.Sizeof(a))
	fmt.Printf("want: %d, got: %d\n", 8+4+2+2, unsafe.Sizeof(ss))
}
