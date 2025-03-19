package main

import (
	"bufio"
	"flag"
	"fmt"
	"io"
	"log"
	"net"
	"os"
)

func handleConnection(conn net.Conn) {
	defer conn.Close()

	if _, err := io.Copy(conn, conn); err != nil {
		fmt.Println("Error while copying.")
	}
}

func handleConnectionBuffor(conn net.Conn) {
	defer conn.Close()

	read := bufio.NewReader(conn)
	s, err := read.ReadString('\n')
	if err != nil {
		log.Fatalln("Unable to read data.")
	}
	log.Printf("Read %d bytes: %s", len(s), s)

	log.Println("Writing data.")
	writer := bufio.NewWriter(conn)
	if _, err := writer.WriteString(s); err != nil {
		log.Fatalln("Unable to write data.")
	}
	writer.Flush()
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

		go handleConnection(conn)
	}
}
