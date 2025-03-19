package main

import (
	"context"
	"log"

	pb "grpc-go/greet/proto"
)

func doGreet(client pb.GreetServiceClient) {
	log.Println("Function doGreet was invoked.")
	res, err := client.Greet(context.Background(), &pb.GreetRequest{
		FirstName: "Lumpy",
	})

	if err != nil {
		log.Fatalf("Could not greet: %v\n", err)
	}

	log.Printf("Greeting: %s\n", res.Result)

}
