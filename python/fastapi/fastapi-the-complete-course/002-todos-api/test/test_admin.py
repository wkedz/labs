

from .utils import override_get_current_user, override_get_db, client, TestSessionLocal
from routers.admin import get_db
from routers.auth import get_current_user
from main import app
from models import Todos
from fastapi import status

app.dependency_overrides[get_db] = override_get_db
app.dependency_overrides[get_current_user] = override_get_current_user


def test_admin_read_all_authenticated(todo: Todos) -> None:
    response = client.get("/admin/todo")
    assert response.status_code == status.HTTP_200_OK
    assert response.json() == [
        {
            "complete": todo.complete,
            "description": todo.description,
            "id": todo.id,
            "owner_id": todo.owner_id,
            "priority": todo.priority,
            "title": todo.title,
        }
    ]


def test_admin_delete_todo(todo: Todos) -> None:
    response = client.delete("/admin/todo/1")
    assert response.status_code == status.HTTP_204_NO_CONTENT
    db = TestSessionLocal()
    model = db.query(Todos).filter(Todos.id == 1).first()
    assert model is None, "The todo should be deleted"


def test_admin_delete_todo_not_found(todo: Todos) -> None:
    response = client.delete("/admin/todo/999")
    assert response.status_code == status.HTTP_404_NOT_FOUND
    assert response.json() == {"detail": "Todo not found."}