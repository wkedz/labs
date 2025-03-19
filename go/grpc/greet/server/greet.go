package main

import (
	"context"
	"log"

	pb "grpc-go/greet/proto"
)

// Implementation of Greet server. We need to define all functions from interface generated in greet_grpc.pb.go
func (s *Server) Greet(ctx context.Context, in *pb.GreetRequest) (*pb.GreetResponse, error) {
	log.Printf("Greet function was invoked with: %v\n", in)
	return &pb.GreetResponse{
		Result: "Hello " + in.FirstName,
	}, nil
}
