package main

import (
	"fmt"
	"time"
)

var ch1 chan int = make(chan int)
var ch2 chan int = make(chan int)

func read() {
	for {
		select {
		// case i, ok := <-ch1:
		// 	fmt.Println("ch1", i, ",", ok)
		// case i, ok := <-ch2:
		// 	fmt.Println("ch2", i, ",", ok)
		default:
			time.Sleep(1 * time.Second)
			fmt.Println("a ...any")
		}
	}
}

func get_ch1() int {
	fmt.Println("get_ch1")
	return <-ch1
}

func get_ch2() int {
	fmt.Println("get_ch2")
	return <-ch2
}

func send_data() {
	for i := 0; i < 20; i++ {
		select {
		case ch1 <- 1:
			fmt.Println("ch1 <- 1:")
		case ch2 <- 2:
			fmt.Println("ch2 <- 2:")
		}
	}
}

func main() {
	go read()
	go send_data()
	time.Sleep(2 * time.Second)
	get_ch1()
	time.Sleep(2 * time.Second)
	get_ch2()
	time.Sleep(2 * time.Second)
	close(ch1)
	close(ch2)
}
