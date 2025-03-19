package main

import (
	"fmt"
	"time"
)

type city struct {
	name     string
	location string
}

func createCity(record city) {
	time.Sleep(10 * time.Millisecond)
}

func readData(cityChn chan []city) {
	var cities []city

	lines := []string{"1", "2", "3", "4", "1", "2", "3", "4", "1", "2", "3", "4", "1", "2", "3", "4", "1", "2", "3", "4"}
	for _, line := range lines {
		cities = append(cities, city{
			name:     line,
			location: line,
		})
	}

	cityChn <- cities
}

func worker(cityChn chan city) {
	for val := range cityChn {
		createCity(val)
	}
}

func main() {
	startTime := time.Now()
	cities := make(chan []city)
	go readData(cities)

	const workers = 5
	jobs := make(chan city, 4)

	for w := 1; w <= workers; w++ {
		go worker(jobs)
	}

	// this one does not need to be closed...
	for _, val := range <-cities {
		jobs <- val
	}

	// this one requires to cities to be explicit close
	for val := range cities {
		for _, v := range val {
			jobs <- v
		}
	}

	fmt.Println("total time ", time.Since(startTime))
}
