package main

import (
	"bufio"
	"fmt"
	"log"
	"os"
	"strconv"
	"strings"

	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"

	pb "grpc-go/calculator/proto"
)

var server_address = "localhost:50051"

func returnDigit(input_digit string) (int32, error) {

	digit, err := strconv.ParseInt(input_digit, 0, 32)
	if err != nil {
		return 0, fmt.Errorf("given argument is not a digit: %v", input_digit)
	}
	return int32(digit), nil
}

func prepareInput(input string) []string {
	return strings.Split(strings.TrimSpace(input), " ")
}

func getCalculationDigits(digits []string) (int32, int32) {
	if len(digits) != 3 {
		log.Fatalf("Invalid input.")
	}

	f_digit, err := returnDigit(digits[1])
	if err != nil {
		log.Fatalf("First argument is not a digit.")
	}

	s_digit, err := returnDigit(digits[2])
	if err != nil {
		log.Fatalf("Second argument is not a digit")
	}

	return f_digit, s_digit
}

func getPrimeDigit(digits []string) int32 {
	if len(digits) != 2 {
		log.Fatalf("Invalid input.")
	}

	digit, err := returnDigit(digits[1])
	if err != nil {
		log.Fatalf("First argument is not a digit.")
	}

	return digit
}

func getDigits(input []string) []int32 {
	if len(input) < 2 {
		log.Fatalf("Invalid input.")
	}

	prepared_digits := make([]int32, 0)
	_input := input[1:]
	for _, i := range _input {
		extracted_digit, err := returnDigit(i)
		if err != nil {
			log.Fatalf("First argument is not a digit.")
		}
		prepared_digits = append(prepared_digits, extracted_digit)
	}
	return prepared_digits
}

func main() {
	log.Print("Init client.")

	conn, err := grpc.NewClient(server_address, grpc.WithTransportCredentials(insecure.NewCredentials()))

	if err != nil {
		log.Fatalf("Failed to make connection to: %v\n", server_address)
	}

	defer conn.Close()
	client := pb.NewCalculatorServiceClient(conn)
	reader := bufio.NewReader(os.Stdin)

	for {
		log.Print("Enter a command (a, s, m, d, q) and digit example: a 2 3: ")
		input, err := reader.ReadString('\n')
		if err != nil {
			log.Println("Error reading input:", err)
			continue
		}

		prepared_input := prepareInput(input)

		switch strings.ToLower(prepared_input[0]) {
		case "a":
			f, s := getCalculationDigits(prepared_input)
			doAdd(client, f, s)
		case "s":
			f, s := getCalculationDigits(prepared_input)
			doSubstract(client, f, s)
		case "m":
			f, s := getCalculationDigits(prepared_input)
			doMultiply(client, f, s)
		case "d":
			f, s := getCalculationDigits(prepared_input)
			doDivine(client, f, s)
		case "p":
			d := getPrimeDigit(prepared_input)
			doPrime(client, d)
		case "v":
			d := getDigits(prepared_input)
			doAverege(client, d)
		case "q":
			log.Println("Quiting...")
			return
		default:
			log.Println("Invalid command. Only a, s, m, d, or q are handled.")
		}
	}
}
