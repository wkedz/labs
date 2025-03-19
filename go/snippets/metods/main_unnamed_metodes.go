package main

import (
	"fmt"
	"sync"
)

type map_s_s map[string]string

var (
	mu      sync.Mutex
	mapping = make(map_s_s)
)

//Ciekawy trick
var cache = struct {
	sync.Mutex
	mapping map_s_s
}{
	mapping: make(map_s_s),
}

func Lookup0(key string) string {
	mu.Lock()
	v := mapping[key]
	mu.Unlock()
	return v
}

func Lookup1(key string) string {
	cache.Lock()
	v := cache.mapping[key]
	cache.Unlock()
	return v
}

func main() {
	mapping["derp"] = "derp"
	cache.mapping["derp"] = "derp"

	fmt.Println(Lookup0("derp"))
	fmt.Println(Lookup1("derp"))
}
