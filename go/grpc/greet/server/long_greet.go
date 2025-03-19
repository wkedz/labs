package main

import (
	"fmt"
	pb "grpc-go/greet/proto"
	"io"
	"log"

	"google.golang.org/grpc"
)

func (s *Server) LongGreet(in grpc.ClientStreamingServer[pb.GreetRequest, pb.GreetResponse]) error {
	log.Println("Invoke LongGreet.")

	res := ""
	for {
		req, err := in.Recv()
		if err == io.EOF {
			return in.SendAndClose(&pb.GreetResponse{
				Result: res,
			})
		}

		if err != nil {
			log.Fatalf("Error while reading client stream: %v.\n", err)
		}
		res += fmt.Sprintf("Hello %s!\n", req.FirstName)
	}
}
