package main

import "fmt"

func main() {
	words := []string{"a", "cow", "smile", "gopher"}
	for _, word := range words {
		switch size := len(word); size {
		case 1, 2:
			fmt.Println(word, "is a short word.")
		case 3:
			fmt.Println(word, "is enough.")
		case 4, 5:
			fmt.Println(word, "is a long word.")
		}
	}

	aa := []int{1, 2}
	for _, a := range aa {
		switch a {
		case 1:
			fmt.Println("not empty", a)
		case 2:
			fmt.Println("not empty", a)
		}
	}

	for _, a := range aa {
		switch {
		case a == 1:
			fmt.Println("empty", a)
		case a == 2:
			fmt.Println("empty", a)
		}
	}

}
