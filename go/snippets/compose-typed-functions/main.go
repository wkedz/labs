package main

import (
	"crypto/sha256"
	"encoding/hex"
	"fmt"
)

type TransformerFunc func(string) string

type Transformer struct {
	transformer TransformerFunc
}

func (t *Transformer) transform(name string) error {
	transformed_name := t.transformer(name)
	fmt.Println(transformed_name)
	return nil
}

func hash256(name string) string {
	hash := sha256.Sum256([]byte(name))
	new_filename := hex.EncodeToString(hash[:])
	return new_filename
}

func prefixer(prefix string) TransformerFunc {
	return func(name string) string {
		return prefix + name
	}
}

func main() {
	th := Transformer{
		transformer: hash256,
	}
	th.transform("transform")

	tp := Transformer{
		transformer: prefixer("prefix_"),
	}
	tp.transform("transform")
}
