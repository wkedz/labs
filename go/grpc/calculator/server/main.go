package main

import (
	"log"
	"net"

	pb "grpc-go/calculator/proto"

	"google.golang.org/grpc"
)

var address = "0.0.0.0:50051"

type CalculatorServer struct {
	pb.CalculatorServiceServer
}

func main() {
	log.Println("Start")

	list, err := net.Listen("tcp", address)

	if err != nil {
		log.Fatalf("Failed to start server on: %v\n", address)
	}

	log.Printf("Server is listening on: %v\n", address)

	grpc_server := grpc.NewServer()
	calulator_server := &CalculatorServer{}
	pb.RegisterCalculatorServiceServer(grpc_server, calulator_server)

	if err := grpc_server.Serve(list); err != nil {
		log.Fatalf("Failed to start Calculator Server.")
	}
}
