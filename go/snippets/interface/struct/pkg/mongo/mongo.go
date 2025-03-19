package mongo_repo

import (
	"context"
	"interface-struct/pkg/user"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
)

type MongoUserRow struct {
	collection *mongo.Collection
}

func (r *MongoUserRow) GetUserByID(id int64) (*user.User, error) {
	filter := bson.M{"id": id}
	user := &user.User{}
	err := r.collection.FindOne(context.Background(), filter).Decode(user)
	if err != nil {
		return nil, err
	}
	return user, nil
}

func NewMongoUserRow(collection *mongo.Collection) *MongoUserRow {
	return &MongoUserRow{collection: collection}
}
