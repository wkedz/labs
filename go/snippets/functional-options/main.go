package main

import "fmt"

type OptsFunc func(opt *Opts)

type Opts struct {
	macConn int
	name    string
	timeout int
	tls     bool
}

type Server struct {
	Opts
}

func defaultOpts() Opts {
	return Opts{
		macConn: 100,
		name:    "default",
		timeout: 100,
		tls:     false,
	}
}

func withMaxConn(conn int) OptsFunc {
	return func(opt *Opts) {
		opt.macConn = conn
	}
}

func withName(name string) OptsFunc {
	return func(opt *Opts) {
		opt.name = name
	}
}

func withTimeout(timeout int) OptsFunc {
	return func(opt *Opts) {
		opt.timeout = timeout
	}
}

func withTls(opt *Opts) {
	opt.tls = true
}

func newServer(opts ...OptsFunc) Server {
	defaultOpts := defaultOpts()

	for _, fn := range opts {
		fn(&defaultOpts)
	}

	return Server{
		Opts: defaultOpts,
	}
}

func main() {
	server := newServer(withTls, withMaxConn(1000))
	fmt.Printf("%+v\n", server)
}
