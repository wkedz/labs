package main

import (
	"fmt"
	"io"
	"net/http"
	"os"
	"strconv"
)

type counter struct {
	total       uint64
	to_download uint64
}

func (c *counter) Write(b []byte) (int, error) {
	c.total += uint64(len(b)) //32kb at a time
	fmt.Printf("\rt: %.2f%%", 100*(float64(c.total)/float64(c.to_download)))
	return len(b), nil
}

func checkIfFileExists(fileName string) (bool, error) {

	_, err := os.Stat(fileName)

	if os.IsNotExist(err) {
		return false, nil
	} else if err != nil {
		return false, err
	} else {
		// We could check if this is a dir, but we dont need to.
		return true, nil
	}
}

func main() {
	res, err := http.Get("http://storage.googleapis.com/books/ngrams/books/googlebooks-eng-all-5gram-20120701-0.gz")
	if err != nil {
		panic(err)
	}

	body_length, err := strconv.Atoi(res.Header.Get("Content-Length"))
	fmt.Printf("res.Header.Get(\"Content-Length\"): %v\n", body_length/(1024*1024))

	local, err := os.OpenFile("download-5gram.txt", os.O_CREATE|os.O_WRONLY, 0600)
	if err != nil {
		panic(err)
	}

	defer local.Close()
	// dec, err := gzip.NewReader(res.Body)
	// if err != nil {
	// 	panic(err)
	// }

	//io.MultiWriter()
	//io.MultiReader()

	if _, err := io.Copy(local, io.TeeReader(res.Body, &counter{to_download: uint64(body_length)})); err != nil {
		panic(err)
	}
}
