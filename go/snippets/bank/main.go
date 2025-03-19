// Package bank implementuje współbieżnie bezpieczny bank z jednym kontem.
package main

import (
	"fmt"
	"time"
)

var deposits = make(chan int) // wysyłanie kwoty do wpłaty
var balances = make(chan int) // odbieranie salda
func Deposit(amount int)      { deposits <- amount }
func Balance() int            { return <-balances }
func teller() {
	var balance int // zmienna balance jest zamknięta w funkcji goroutine teller
	for {
		select {
		case amount := <-deposits:
			fmt.Println("amount := <-deposits:")
			balance += amount
		case balances <- balance:
			fmt.Println("balances <- balance:")
		}
	}
}
func main() {
	go teller()
	time.Sleep(10 * time.Second)
	fmt.Println(Balance())
	fmt.Println(Balance())
	fmt.Println(Balance())
	Deposit(10)
	fmt.Println(Balance())
	time.Sleep(10 * time.Second)
}
