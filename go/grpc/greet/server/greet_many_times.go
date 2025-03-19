package main

import (
	"fmt"
	pb "grpc-go/greet/proto"
	"log"

	"google.golang.org/grpc"
)

func (s *Server) GreetManyTimes(in *pb.GreetRequest, out grpc.ServerStreamingServer[pb.GreetResponse]) error {
	log.Printf("Called GreetManyTimes with: %v\n", in)

	for i := 0; i < 10; i++ {
		response := &pb.GreetResponse{
			Result: fmt.Sprintf("Hello %s, nr %d", in.FirstName, i),
		}

		if err := out.Send(response); err != nil {
			return err
		}
	}

	return nil
}
