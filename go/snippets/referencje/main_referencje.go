package main

import "fmt"

/*
Modyfikacje kopii nie mają wpływu na podmiot wywołujący. Jeśli jednak argument zawiera jakieś
referencje (jak wskaźnik, wycinek, mapa, funkcja lub kanał)

*/

var v int = 5
var s []int = []int{1, 2, 3}
var a [3]int = [3]int{1, 2, 3}
var m map[string]int = map[string]int{"1": 1, "2": 2, "3": 3}

func array(a [3]int) {
	// no changes - passed by value
	a[0] = 4
}

func arrayPtr(a *[3]int) {
	// changes - passed by ptr
	a[0] = 8
}

func slice(s []int) {
	// changes - passed by ref
	s[0] = 4
}

func slicePtr(s *[]int) {
	// changes - passed by ptr
	(*s)[0] = 8
}

func mapp(m map[string]int) {
	// Changes - passed by ref
	m["1"] = 4
}

func mapPtr(m *map[string]int) {
	//Changes - passed by ptr
	(*m)["1"] = 8
}

func main() {
	array(a)
	fmt.Println(a)
	arrayPtr(&a)
	fmt.Println(a)

	slice(s)
	fmt.Println(s)
	slicePtr(&s)
	fmt.Println(s)

	mapp(m)
	fmt.Println(m)
	mapPtr(&m)
	fmt.Println(m)
}
