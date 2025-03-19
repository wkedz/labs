package main

import "fmt"

func main() {
	var x []int
	x = append(x, 1)
	fmt.Printf("x=%v, len=%d, cap=%d\n", x, len(x), cap(x))
	x = append(x, 2)
	fmt.Printf("x=%v, len=%d, cap=%d\n", x, len(x), cap(x))
	x = append(x, 3)
	fmt.Printf("x=%v, len=%d, cap=%d\n", x, len(x), cap(x))
	y := x
	x = append(x, 4)
	fmt.Printf("x=%v, len=%d, cap=%d\n", x, len(x), cap(x))
	fmt.Printf("y=%v, len=%d, cap=%d\n", y, len(y), cap(y))
	y = append(y, 5)
	// before append y has len 3 and cap 4 and first element points to x[0],
	// so after append it will overwrite last operation on x - append(x,4)
	fmt.Printf("x=%v, len=%d, cap=%d\n", x, len(x), cap(x))
	fmt.Printf("y=%v, len=%d, cap=%d\n", y, len(y), cap(y))

	x[0] = 0

	fmt.Println(x)
	fmt.Println(y)
}
