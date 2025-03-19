package outsidestruct

type Outside string

func (s *Outside) Add() {
	*s += "Add"
}
