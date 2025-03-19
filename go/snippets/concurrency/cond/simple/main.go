package main

import (
	"fmt"
	"sync"
	"time"
)

func main() {

	cond := sync.NewCond(&sync.Mutex{})
	var wg sync.WaitGroup
	wg.Add(2)
	go func() {
		//time.Sleep(time.Second)
		defer wg.Done()
		cond.L.Lock()
		fmt.Println("func1 standing by.")
		cond.Wait()
		fmt.Println("func1 go!")
		cond.L.Unlock()
	}()

	go func() {
		//time.Sleep(time.Second)
		defer wg.Done()
		cond.L.Lock()
		fmt.Println("func2 standing by.")
		cond.Wait()
		fmt.Println("func2 go!")
		cond.L.Unlock()
	}()
	//cond.L.Lock()
	time.Sleep(time.Second)
	cond.L.Lock()
	fmt.Println("Broadcasting")
	cond.Broadcast()
	cond.L.Unlock()
	wg.Wait()

}
