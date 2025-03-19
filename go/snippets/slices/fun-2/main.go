package main

import "fmt"

func main() {
	x := []int{1, 2, 3, 4} // x=[1,2,3,4], len=4, cap=4
	y := x                 // y=[1,2,3,4], len=4, cap=4
	x = append(x, 5)       // x=[1,2,3,4,5], len=5, cap=8
	y = append(y, 6)       // y=[1,2,3,4,6], len=5, cap=8
	x[0] = 0               // x=[0,2,3,4,5], len=5, cap=8

	fmt.Println(x) // x=[0,2,3,4,5], len=5, cap=8
	fmt.Println(y) // y=[1,2,3,4,6], len=5, cap=8
}
