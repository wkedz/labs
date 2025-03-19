package main

import (
	"log"
	"net"

	pb "grpc-go/greet/proto"

	"google.golang.org/grpc"
)

var address = "0.0.0.0:50051"

type Server struct {
	pb.GreetServiceServer
}

func main() {
	list, err := net.Listen("tcp", address)

	if err != nil {
		log.Fatalf("Failed to listen on: %v\n", err)
	}

	log.Printf("Listening on %s\n", address)

	grpc_server := grpc.NewServer()
	greet_server := &Server{}
	pb.RegisterGreetServiceServer(grpc_server, greet_server)

	if err = grpc_server.Serve(list); err != nil {
		log.Fatalf("Failed to serve: %v\n", err)
	}
}
