package main

import (
	"errors"
	"fmt"
	"unsafe"

	"golang.org/x/sys/unix"
)

func linuxTaskstatsInterface() (int, error) {
	b := []byte{0x01}
	const sizeofTaskstats = int(unsafe.Sizeof(unix.Taskstats{}))
	if sizeofTaskstats != len(b) {
		return 0, errors.New("unexpected taskstats structure size.")
	}
	stats := *(*unix.Taskstats)(unsafe.Pointer(&b[0]))
	fmt.Println(stats)
	return 0, nil
}

func uint16to2byte() {
	// usefull for system endianes check
	a := uint16(1)
	if unsafe.Sizeof(a) != 2 {
		panic("a is not of the expected size.")
	}

	b := *(*[2]byte)(unsafe.Pointer(&a))
	fmt.Println(b)
	// [1 0] -> little endian
	// [0 1] -> big endian
}

func simple() {
	i := 10
	iptr := unsafe.Pointer(&i)
	// All will print an address of i
	fmt.Println(&i)
	fmt.Println(iptr)
	fmt.Println((*int)(iptr)) //address of

	// This will print an address of iptr
	fmt.Println(&iptr)

	// Value of variable pointing to by iptr
	fmt.Println(*(*int)(iptr))
}

func array() {
	arr := []int{1, 2, 3, 4, 5, 6}
	arrPtr := unsafe.Pointer(&arr[0])
	for i := 0; i < len(arr); i++ {
		val := (*int)(unsafe.Pointer(uintptr(arrPtr) + uintptr(i)*unsafe.Sizeof(arr[0])))
		fmt.Println(val, " : ", *val)
	}
}

func main() {
	simple()
	array()
	uint16to2byte()
}
