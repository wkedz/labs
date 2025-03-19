package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
	"strconv"
	"sync"
)

type CounterStore struct {
	sync.RWMutex
	coutners map[string]int
}

func (cs *CounterStore) get(w http.ResponseWriter, r *http.Request) {
	fmt.Printf("get r: %v\n", r)
	name := r.URL.Query().Get("name")
	cs.RLock()
	defer cs.Unlock()
	if val, ok := cs.coutners[name]; ok {
		fmt.Fprintf(w, "%s: %d\n", name, val)
	} else {
		fmt.Fprintf(w, "%s not found", name)
	}
}

func (cs *CounterStore) set(w http.ResponseWriter, r *http.Request) {
	fmt.Printf("set r: %v\n", r)
	name := r.URL.Query().Get("name")
	val := r.URL.Query().Get("val")
	intval, err := strconv.Atoi(val)
	if err != nil {
		fmt.Fprintf(w, "%s\n", err)
	} else {
		cs.Lock()
		defer cs.Unlock()
		cs.coutners[name] = intval
		fmt.Fprintf(w, "ok\n")
	}
}

func (cs *CounterStore) inc(w http.ResponseWriter, r *http.Request) {
	fmt.Printf("inc r: %v\n", r)
	name := r.URL.Query().Get("name")
	cs.Lock()
	defer cs.Unlock()
	if _, ok := cs.coutners[name]; ok {
		cs.coutners[name]++
		fmt.Fprintf(w, "ok\n")
	} else {
		fmt.Fprintf(w, "%s not found\n", name)
	}
}

func main() {
	store := CounterStore{
		coutners: map[string]int{"i": 0, "j": 0},
	}

	mux := http.NewServeMux()
	//Use wraper aroung Handler function, so it could be use as handler (implements ServeHTTP)
	mux.HandleFunc("/get", store.get)
	mux.HandleFunc("/set", store.set)
	mux.HandleFunc("/inc", store.inc)

	//mux.Handle("/get", store.get) // missing ServeHTTP function
	//mux.Handle("/set", store.set) // missing ServeHTTP function
	//mux.Handle("/inc", store.inc) // missing ServeHTTP function

	portnum := 8000
	if len(os.Args) > 1 {
		portnum, _ = strconv.Atoi(os.Args[1])
	}

	log.Printf("Server listing on port %d\n", portnum)
	log.Fatal(http.ListenAndServe("localhost:"+strconv.Itoa(portnum), mux))
}
