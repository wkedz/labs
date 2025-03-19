package main

import (
	"context"
	"fmt"
	pb "grpc-go/greet/proto"
	"log"
)

func doLongGreet(in pb.GreetServiceClient) {
	log.Println("Invoke doLongGreet")

	stream, err := in.LongGreet(context.Background())

	if err != nil {
		log.Fatalf("Error while creating LongGreet: %v.\n", err)
	}

	names := [4]string{"Wojtus", "Bartus", "Sandra", "Buniek"}
	for _, name := range names {
		if err := stream.Send(&pb.GreetRequest{
			FirstName: name,
		}); err != nil {
			log.Fatalf("Error while sending message to server.")
		}
	}

	res, err := stream.CloseAndRecv()
	if err != nil {
		log.Fatalf("Error while closing connection")
	}

	fmt.Printf("Response: %v.\n", res.Result)
}
