package main

import (
	"fmt"
	"sync"
	"time"
)

func main() {
	started := time.Now()
	foods := []string{"sandwich", "pizza", "pasta", "icecream"}
	var wg sync.WaitGroup
	wg.Add(len(foods))
	for _, f := range foods {
		go func(s string) {
			eat(s)
			wg.Done()
		}(f)
	}
	wg.Wait()
	fmt.Printf("I ate all in %v\n", time.Since(started))
}

func eat(s string) {
	fmt.Printf("Yhhmmm, delicious %s ...\n", s)
	time.Sleep(time.Second * 2)
	fmt.Printf("I ate %s.\n", s)
}
