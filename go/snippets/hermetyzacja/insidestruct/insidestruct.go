package insidestruct

type Inside struct {
	words string
}

func (s *Inside) Add() {
	s.words += "Add"
}
