package main

import "fmt"

type Status int

const (
	InvalidLogin Status = iota + 1
	NotFound
)

type StatusErr struct {
	Status
	Message string
}

func (se StatusErr) Error() string {
	return se.Message
}

func GenerateError(flag bool) error {
	var genErr StatusErr
	if flag {
		genErr = StatusErr{
			Status: NotFound,
		}
	}
	return genErr
}

func GenerateError2(flag bool) error {
	if flag {
		return StatusErr{
			Status: NotFound,
		}
	}
	return nil
}

func GenerateError3(flag bool) error {
	var genErr error
	if flag {
		genErr = StatusErr{
			Status: NotFound,
		}
	}
	return genErr
}

func main() {

	err := GenerateError2(true)
	fmt.Println(err != nil)
	err = GenerateError2(false)
	fmt.Println(err != nil)
	// It prints true true because GenerateError is returning getErr. Even if it is not initialized
	// error is interface, and in order to error be strict null it both pointers nned to point to nil
}
