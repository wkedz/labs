package main

import (
	"fmt"
	"io"
	"log"
	"os"
)

type FooReader struct{}
type FooWriter struct{}

func (fr FooReader) Read(b []byte) (int, error) {
	fmt.Print("<<")
	return os.Stdin.Read(b)
}

func (fw FooWriter) Write(b []byte) (int, error) {
	fmt.Print(">>")
	return os.Stdout.Write(b)
}

func main() {
	var (
		rd FooReader
		wr FooWriter
	)

	buffor := make([]byte, 4096)
	s, err := rd.Read(buffor)
	if err != nil {
		log.Fatalln("Unable to read data.")
	}
	fmt.Printf("Read %d bytes from stdin\n", s)

	s, err = wr.Write(buffor)
	if err != nil {
		log.Fatalln("Unable to write data")
	}
	fmt.Printf("Wrote %d bytes to stdout\n", s)

	fmt.Println("With copy.")
	if _, err := io.Copy(wr, rd); err != nil {
		fmt.Errorf("Unable to read/write data\n.")
	}

}
