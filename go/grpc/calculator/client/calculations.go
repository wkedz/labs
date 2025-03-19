package main

import (
	"context"
	"fmt"
	pb "grpc-go/calculator/proto"
	"io"
	"log"

	"google.golang.org/grpc"
)

type CalculationFunction func(context.Context, *pb.Calculate, ...grpc.CallOption) (*pb.Result, error)

func doCalculationAction(fn CalculationFunction, f, s int32) {
	result, err := fn(context.Background(), &pb.Calculate{
		First:  f,
		Second: s,
	})
	printResult(result, err)
}

func printResult(result *pb.Result, err error) {
	if err != nil {
		log.Printf("An error occures: %v", err)
	} else {
		log.Printf("Result is: %d", result.Result)
	}
}

func doAdd(client pb.CalculatorServiceClient, f, s int32) {
	log.Printf("Calling Add with %d, %d", f, s)
	doCalculationAction(client.Add, f, s)
}

func doSubstract(client pb.CalculatorServiceClient, f, s int32) {
	log.Printf("Calling Substract with %d, %d", f, s)
	doCalculationAction(client.Subtract, f, s)
}

func doMultiply(client pb.CalculatorServiceClient, f, s int32) {
	log.Printf("Calling Multiply with %d, %d", f, s)
	doCalculationAction(client.Multiply, f, s)
}

func doDivine(client pb.CalculatorServiceClient, f, s int32) {
	log.Printf("Calling Divine with %d, %d", f, s)
	doCalculationAction(client.Divine, f, s)
}

func doPrime(client pb.CalculatorServiceClient, p int32) {
	log.Printf("Calling Prime with %d", p)
	stream, err := client.Primes(context.Background(), &pb.Prime{
		Prime: p,
	})

	if err != nil {
		log.Fatalf("Error while calling with %v\n", p)
	}

	results := make([]int32, 3)
	for {
		result, err := stream.Recv()
		if err == io.EOF {
			log.Println("End Of File. Closing.")
			break
		}

		if err != nil {
			log.Fatalf("An error occures %v while receiving data.\n", result)
		}
		results = append(results, result.Result)
	}
	fmt.Printf("results: %v\n", results)
}

func doAverege(client pb.CalculatorServiceClient, p []int32) {
	log.Printf("Calling doAverege with %v.", p)

	stream, err := client.Averege(context.Background())
	if err != nil {
		log.Fatalf("Error while calling doAverege %v.\n", err)
	}

	for _, digit := range p {
		log.Printf("Sending: %d", digit)
		if err := stream.Send(&pb.Number{
			Number: digit,
		}); err != nil {
			log.Fatalf("Error while sending data to server.")
		}
	}

	result, err := stream.CloseAndRecv()

	log.Printf("Result: %d.\n", result.Result)

	if err != nil {
		log.Fatalf("Error while getting response %v.", err)
	}

}
