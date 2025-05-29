from fastapi import status

from models import Users
from .utils import override_get_current_user, override_get_db, client
from routers.users import get_current_user, get_db

from main import app


app.dependency_overrides[get_db] = override_get_db
app.dependency_overrides[get_current_user] = override_get_current_user

def test_return_user(user : Users) -> None:
    response = client.get("/users/get_user")
    assert response.status_code == status.HTTP_200_OK
    response_json = response.json()
    assert response_json["username"] == user.username
    assert response_json["first_name"] == user.first_name
    assert response_json["last_name"] == user.last_name
    assert response_json["role"] == user.role
    
def test_change_password_success(user : Users):
    response = client.put("/users/password", json={"password": "testpassword",
                                                  "new_password": "newpassword"})
    assert response.status_code == status.HTTP_204_NO_CONTENT


def test_change_password_invalid_current_password(user : Users):
    response = client.put("/users/password", json={"password": "wrong_password",
                                                  "new_password": "newpassword"})
    assert response.status_code == status.HTTP_401_UNAUTHORIZED
    assert response.json() == {'detail': 'Error on password change'}    