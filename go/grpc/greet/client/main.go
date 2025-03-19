package main

import (
	"log"

	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"

	pb "grpc-go/greet/proto"
)

var address string = "localhost:50051"

func main() {

	// conn, err := grpc.Dial(address, grpc.WithTransportCredentials(insecure.NewCredentials())) Dial is deprecated in favour for NewClient

	// GRPC is secured by default, so we need to explicity add insecure credentials.
	conn, err := grpc.NewClient(address, grpc.WithTransportCredentials(insecure.NewCredentials()))

	if err != nil {
		log.Fatalf("Failed to connect: %v\n", err)
	}

	defer conn.Close()

	client := pb.NewGreetServiceClient(conn)

	//doGreet(client)
	//doManyTimes(client)
	doLongGreet(client)
}
