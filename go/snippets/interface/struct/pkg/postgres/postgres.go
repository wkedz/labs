package postgres_repo

import (
	"context"
	"interface-struct/pkg/user"

	"github.com/jackc/pgx/v4"
)

type PgxUserRow struct {
	conn *pgx.Conn
}

func (r *PgxUserRow) GetUserByID(id int64) (*user.User, error) {
	query := "SELECT id, name, email FROM users WHERE id = $1"
	user := &user.User{}
	err := r.conn.QueryRow(context.Background(), query, id).Scan(&user.Id, &user.Name, &user.Email)
	if err != nil {
		return nil, err
	}
	return user, nil
}

func NewPgxUserRow(conn *pgx.Conn) *PgxUserRow {
	return &PgxUserRow{conn: conn}
}
