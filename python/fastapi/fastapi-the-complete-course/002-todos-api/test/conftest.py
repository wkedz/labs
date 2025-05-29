from sqlalchemy import text

import pytest
from models import Todos, Users
from routers.auth import bcrypt_context
from .utils import TestSessionLocal, engine

from typing import Generator

@pytest.fixture
def todo() -> Generator[Todos, None, None]:
    todo = Todos(
        title="Test Todo",
        description="This is a test todo item",
        priority=1,
        complete=False,
        owner_id=1
    )

    db = TestSessionLocal()
    db.add(todo)
    db.commit()
    yield todo
    with engine.connect() as connection:
        connection.execute(text("DELETE FROM todos;"))
        connection.commit()

@pytest.fixture
def user() -> Generator[Users, None, None]:
    user = Users(
        username="testuser",
        email="ziutek@oo.ff",
        first_name="tester",
        last_name="tester",
        hashed_password=bcrypt_context.hash("testpassword"),
        role="admin",
    )

    db = TestSessionLocal()
    db.add(user)
    db.commit()
    yield user
    with engine.connect() as connection:
        connection.execute(text("DELETE FROM users;"))
        connection.commit()    