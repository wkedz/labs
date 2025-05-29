from fastapi import status

from .utils import client, TestSessionLocal, override_get_current_user, override_get_db
from routers.admin import get_current_user, get_db
from main import app

from models import Todos

app.dependency_overrides[get_db] = override_get_db
app.dependency_overrides[get_current_user] = override_get_current_user

def test_read_all_authenticated(todo: Todos) -> None:
    response = client.get("/")
    assert response.status_code == status.HTTP_200_OK
    assert response.json() == [{'complete': False,
                              'description': 'This is a test todo item',
                              'id': 1,
                              'owner_id': 1,
                              'priority': 1,
                              'title': 'Test Todo'}]


def test_read_one_authenticated(todo: Todos) -> None:
    response = client.get("/todo/1")
    assert response.status_code == status.HTTP_200_OK
    assert response.json() == {'complete': False,
                              'description': 'This is a test todo item',
                              'id': 1,
                              'owner_id': 1,
                              'priority': 1,
                              'title': 'Test Todo'}


def test_read_one_authenticated_not_found(todo: Todos) -> None:
    response = client.get("/todo/999")
    assert response.status_code == status.HTTP_404_NOT_FOUND
    assert response.json() == {'detail': 'Todo not found.'}    


def test_create_todo(todo: Todos) -> None:
    request_data = {
        "title": "New Todo",
        "description": "New todo",
        "priority": 2,
        "complete": False
    }
    response = client.post("/todo", json=request_data)
    assert response.status_code == status.HTTP_201_CREATED

    db = TestSessionLocal()
    model = db.query(Todos).filter(Todos.id == 2).first()
    assert model is not None
    assert model.title == request_data["title"]
    assert model.description == request_data["description"]
    assert model.priority == request_data["priority"]
    assert model.complete == request_data["complete"]

def test_update_todo(todo: Todos) -> None:
    request_data = {
        "title": "upadted Todo",
        "description": "update",
        "priority": 3,
        "complete": False
    }
    response = client.put("/todo/1", json=request_data)
    assert response.status_code == status.HTTP_204_NO_CONTENT

    db = TestSessionLocal()
    model = db.query(Todos).filter(Todos.id == 1).first()
    assert model is not None
    assert model.title == request_data["title"]
    assert model.description == request_data["description"]
    assert model.priority == request_data["priority"]
    assert model.complete == request_data["complete"]

def test_update_todo_not_found(todo: Todos) -> None:
    request_data = {
        "title": "upadted Todo",
        "description": "update",
        "priority": 3,
        "complete": False
    }
    response = client.put("/todo/999", json=request_data)
    assert response.status_code == status.HTTP_404_NOT_FOUND
    assert response.json() == {'detail': 'Todo not found.'}

def test_delete_todo(todo: Todos) -> None:
    response = client.delete("/todo/1")
    assert response.status_code == status.HTTP_204_NO_CONTENT
    db = TestSessionLocal()
    model = db.query(Todos).filter(Todos.id == 1).first()
    assert model is None

def test_delete_todo_not_found(todo: Todos) -> None:
    response = client.delete("/todo/999")
    assert response.status_code == status.HTTP_404_NOT_FOUND
    assert response.json() == {'detail': 'Todo not found.'}