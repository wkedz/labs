package main

import "fmt"

func main() {
con:
	for i := 0; i < 10; i++ {
		fmt.Println("ci :", i)
		if i == 6 {
			continue con
		}
	}

bre:
	for i := 0; i < 10; i++ {
		fmt.Println("bi :", i)
		if i == 6 {
			break bre
		}
	}
}
