package main

import "fmt"

func countTo(max int) <-chan int {
	ch := make(chan int)
	go func() {
		for i := 0; i < max; i++ {
			ch <- i
			fmt.Println("c", i)
		}
		close(ch)
	}()
	return ch
}

func main() {
	for i := range countTo(10) {
		fmt.Println(i)
	}
}
