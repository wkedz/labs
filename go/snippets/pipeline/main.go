package main

import "fmt"

func naturals(out chan<- int) {
	for i := 0; i < 100; i++ {
		out <- i
	}
	close(out)
}

func squared(out chan<- int, in <-chan int) {
	for i := range in {
		out <- i * i
	}
	close(out)
}

func result(in <-chan int) {
	for i := range in {
		fmt.Println(i)
	}
}

func main() {
	nat := make(chan int)
	squ := make(chan int)
	go naturals(nat)
	go squared(squ, nat)
	result(squ)
}
