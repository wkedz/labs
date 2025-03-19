package main

import "fmt"

func ConcatStr(m map[string]string) string {
	var s string
	for _, v := range m {
		s += v
	}
	return s
}

func ConcatInt(m map[string]int) int {
	var s int
	for _, v := range m {
		s += v
	}
	return s
}

func ConcatGeneric1[K comparable, V string | int](m map[K]V) V {
	var s V
	for _, v := range m {
		s += v
	}
	return s
}

type Concat interface {
	string | int
}

func ConcatGeneric2[K comparable, V Concat](m map[K]V) V {
	var s V
	for _, v := range m {
		s += v
	}
	return s

}

func main() {
	mSI := map[string]int{
		"f": 1,
		"s": 2,
		"t": 3,
	}

	mSS := map[string]string{
		"f": "1",
		"s": "2",
		"t": "3",
	}

	fmt.Println("--- 1 ---\n", ConcatInt(mSI))
	fmt.Println("--- 2 ---\n", ConcatStr(mSS))
	fmt.Println("--- 3 ---\n", ConcatGeneric1(mSI))
	fmt.Println("--- 4 ---\n", ConcatGeneric1(mSS))
	fmt.Println("--- 5 ---\n", ConcatGeneric2(mSI))
	fmt.Println("--- 6 ---\n", ConcatGeneric2(mSS))
}
