package main

import (
	"context"
	"fmt"
	"log"

	"github.com/jackc/pgx/v4"

	mg_wk "interface-struct/pkg/mongo"
	pg_wk "interface-struct/pkg/postgres"
	"interface-struct/pkg/user"

	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

func getUserById(user user.UserRow, id int64) (*user.User, error) {

	return user.GetUserByID(id)
}

func main() {
	dsn := fmt.Sprintf("host=localhost port=5432 user=postgres password=postgres dbname=db sslmode=disable")
	pgx, err := pgx.Connect(context.Background(), dsn)
	if err != nil {
		log.Fatalf("Unable to connect to PostgreSQL: %v", err)
	}
	pg := pg_wk.NewPgxUserRow(pgx)

	fmt.Println(pg)

	client, err := mongo.Connect(context.Background(), options.Client().ApplyURI("mongodb://root:pass@localhost:27017/"))
	mg := mg_wk.NewMongoUserRow(client.Database("test").Collection("users"))

	fmt.Println(mg)

	if err != nil {
		log.Fatalf("Unable to connect to MongoDB: %v", err)
	}
}
