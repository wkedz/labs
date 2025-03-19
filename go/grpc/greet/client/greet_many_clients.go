package main

import (
	"context"
	pb "grpc-go/greet/proto"
	"io"
	"log"
)

func doManyTimes(in pb.GreetServiceClient) {
	log.Printf("Calling doManyTimes with %v\n", in)

	request := pb.GreetRequest{
		FirstName: "Lumpy",
	}

	stream, err := in.GreetManyTimes(context.Background(), &request)
	if err != nil {
		log.Fatalf("Error while calling server %v\n.", err)
	}
	for {
		msg, err := stream.Recv()
		if err == io.EOF {
			log.Println("End Of File. Closing.")
			break
		}

		if err != nil {
			log.Fatalf("An Error occures %v.\n", err)
		}

		log.Printf("Result from server %v.\n", msg.Result)

	}

}
