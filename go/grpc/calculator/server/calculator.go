package main

import (
	"context"
	"errors"
	pb "grpc-go/calculator/proto"
	"io"
	"log"

	"google.golang.org/grpc"
)

func (s *CalculatorServer) Add(ctx context.Context, cal *pb.Calculate) (*pb.Result, error) {
	log.Printf("Calling Add with %v", cal)
	return &pb.Result{
		Result: cal.First + cal.Second,
	}, nil
}

func (s *CalculatorServer) Subtract(ctx context.Context, cal *pb.Calculate) (*pb.Result, error) {
	log.Printf("Calling Subtract with %v", cal)
	return &pb.Result{
		Result: cal.First - cal.Second,
	}, nil
}

func (s *CalculatorServer) Multiply(ctx context.Context, cal *pb.Calculate) (*pb.Result, error) {
	log.Printf("Calling Multiply with %v", cal)
	return &pb.Result{
		Result: cal.First * cal.Second,
	}, nil
}

func (s *CalculatorServer) Divine(ctx context.Context, cal *pb.Calculate) (*pb.Result, error) {
	log.Printf("Calling Divine with %v", cal)
	second := cal.Second

	if second == 0 {
		log.Fatal("Divine by 0 is notimplemented :)")
		return nil, errors.New("Divining by 0 is not implemented :)")
	}
	return &pb.Result{
		Result: cal.First / cal.Second,
	}, nil

}

func (s *CalculatorServer) Primes(in *pb.Prime, out grpc.ServerStreamingServer[pb.Result]) error {
	log.Printf("Invoking Primes with %v\n", in)

	prime_number := in.Prime
	factor := 2
	for prime_number > 1 {
		if prime_number%int32(factor) == 0 {
			result := &pb.Result{
				Result: int32(factor),
			}
			if err := out.Send(result); err != nil {
				log.Printf("An error occuress.")
				return err
			}
			prime_number = prime_number / int32(factor)
		} else {
			factor = factor + 1
		}
	}
	return nil
}

func (s *CalculatorServer) Averege(stream grpc.ClientStreamingServer[pb.Number, pb.Result]) error {
	log.Printf("Invoking Averege")

	args := make([]int32, 0)

	for {
		req, err := stream.Recv()

		log.Printf("Received: %v", req)

		if err == io.EOF {
			var result int32 = 0
			for _, arg := range args {
				result += arg
				log.Printf("Received: %v", result)
			}

			result = result / int32(len(args))
			log.Printf("Avg: %v", result)
			log.Printf("Len: %v", len(args))
			return stream.SendAndClose(&pb.Result{
				Result: int32(result),
			})
		}

		if err != nil {
			log.Printf("Error occures while processing data %v.", err)
			return err
		}

		args = append(args, req.Number)
	}
}
