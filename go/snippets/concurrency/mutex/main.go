package main

import (
	"fmt"
	"sync"
)

func main() {
	var count int
	var lock sync.Mutex

	inc := func() {
		lock.Lock()
		defer lock.Unlock()
		count++
		fmt.Printf("Increment : %d\n", count)
	}

	dec := func() {
		lock.Lock()
		defer lock.Unlock()
		count--
		fmt.Printf("Decrement : %d\n", count)
	}

	var arithmetic sync.WaitGroup
	for i := 0; i <= 5; i++ {
		arithmetic.Add(1)
		go func() {
			defer arithmetic.Done()
			inc()
		}()
	}

	for i := 0; i <= 5; i++ {
		arithmetic.Add(1)
		go func() {
			defer arithmetic.Done()
			dec()
		}()
	}
	arithmetic.Wait()
}
