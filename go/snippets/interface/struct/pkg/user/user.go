package user

type User struct {
	Id    int64  `json:"id"`
	Name  string `json:"name"`
	Email string `json:"email"`
}

type UserRow interface {
	GetUserByID(it int64) (*User, error)
}
