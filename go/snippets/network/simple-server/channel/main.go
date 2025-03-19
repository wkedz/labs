package main

// https://eli.thegreenplace.net/2019/on-concurrency-in-go-http-servers

import (
	"fmt"
	"log"
	"net/http"
	"os"
	"strconv"
)

type CommandType int

const (
	GetCommand = iota
	SetCommand
	IncCommand
)

type Command struct {
	ty        CommandType
	name      string
	val       int
	replyChan chan int
}

type Server struct {
	cmds chan<- Command
}

func startCounterManager(initvals map[string]int) chan<- Command {
	counters := make(map[string]int)
	for k, v := range initvals {
		counters[k] = v
	}

	cmds := make(chan Command)

	go func() {
		for cmd := range cmds {
			switch cmd.ty {
			case GetCommand:
				if val, ok := counters[cmd.name]; ok {
					cmd.replyChan <- val
				} else {
					cmd.replyChan <- -1
				}
			case SetCommand:
				counters[cmd.name] = cmd.val
				cmd.replyChan <- cmd.val
			case IncCommand:
				if _, ok := counters[cmd.name]; ok {
					counters[cmd.name]++
					cmd.replyChan <- counters[cmd.name]
				} else {
					cmd.replyChan <- -1
				}
			default:
				log.Fatal("Unknown command type", cmd.ty)
			}
		}
	}()
	return cmds
}

func (s *Server) get(w http.ResponseWriter, r *http.Request) {
	fmt.Printf("get r: %v\n", r)
	name := r.URL.Query().Get("name")
	replyChan := make(chan int)
	s.cmds <- Command{ty: GetCommand, name: name, replyChan: replyChan}
	reply := <-replyChan

	if reply >= 0 {
		fmt.Fprintf(w, "%s: %d\n", name, reply)
	} else {
		fmt.Fprintf(w, "%s not found\n", name)
	}
}

func (s *Server) set(w http.ResponseWriter, r *http.Request) {
	fmt.Printf("set r: %v\n", r)
	name := r.URL.Query().Get("name")
	val := r.URL.Query().Get("val")
	intval, err := strconv.Atoi(val)
	if err != nil {
		fmt.Fprintf(w, "%s\n", err)
	} else {
		replyChan := make(chan int)
		s.cmds <- Command{ty: SetCommand, name: name, val: intval, replyChan: replyChan}
		_ = <-replyChan
		fmt.Fprintf(w, "ok\n")
	}
}

func (s *Server) inc(w http.ResponseWriter, r *http.Request) {
	fmt.Printf("inc r: %v\n", r)
	name := r.URL.Query().Get("name")
	replyChan := make(chan int)
	s.cmds <- Command{ty: IncCommand, name: name, replyChan: replyChan}
	reply := <-replyChan
	if reply >= 0 {
		fmt.Fprintf(w, "ok\n")
	} else {
		fmt.Fprintf(w, "%s not found\n", name)
	}
}

func main() {
	server := Server{
		startCounterManager(map[string]int{"i": 0, "j": 0}),
	}

	mux := http.NewServeMux()
	//Use wraper aroung Handler function, so it could be use as handler (implements ServeHTTP)
	mux.HandleFunc("/get", server.get)
	mux.HandleFunc("/set", server.set)
	mux.HandleFunc("/inc", server.inc)

	mux.Handle("/get", server.get) // missing ServeHTTP function
	//mux.Handle("/set", store.set) // missing ServeHTTP function
	//mux.Handle("/inc", store.inc) // missing ServeHTTP function

	portnum := 8000
	if len(os.Args) > 1 {
		portnum, _ = strconv.Atoi(os.Args[1])
	}

	log.Printf("Server listing on port %d\n", portnum)
	log.Fatal(http.ListenAndServe("localhost:"+strconv.Itoa(portnum), mux))
}
