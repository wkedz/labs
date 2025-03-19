package main

import (
	"fmt"
	"math/rand"
	"time"
)

type Bank interface {
	GetBalance() int
	Deposit(amount int)
	Withdraw(amount int) error
}

type Bitcoin struct {

}

func main() {

	limiter := make(chan struct{}, 10)
	for i := 0; i <= 100; i++ {
		limiter <- struct{}{}
		go func(i int) {
			fmt.Println("i :", i)
			ii := -1
			for ii != i {
				ii = rand.Int() % 100
				time.Sleep(time.Millisecond * 200)
				continue
			}
			<-limiter
		}(i)
	}
}
