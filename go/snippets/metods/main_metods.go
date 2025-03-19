package main

type Point struct {
	p int
}

func (p Point) D(q Point) int {
	return p.p - q.p
}
