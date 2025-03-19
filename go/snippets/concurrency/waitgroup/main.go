package main

import (
	"fmt"
	"sync"
)

func main() {

	hello := func(wg *sync.WaitGroup, id int) {
		defer wg.Done()
		fmt.Printf("Hello from %v!\n", id)
	}

	const greeters = 5
	var wg sync.WaitGroup
	wg.Add(greeters)
	for i := 0; i < greeters; i++ {
		go hello(&wg, i+1)
	}
	wg.Wait()
}
