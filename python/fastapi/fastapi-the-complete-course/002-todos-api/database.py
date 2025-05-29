from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base
#MovedIn20Warning: The ``declarative_base()`` function is now available as sqlalchemy.orm.declarative_base(). (deprecated since: 2.0) (Background on SQLAlchemy 2.0 at: https://sqlalche.me/e/b8d9)
#    Base = declarative_base()
#from sqlalchemy.ext.declarative import declarative_base


#SQLALCHEMY_DATABASE_URL = "sqlite:///./todos.db"
SQLALCHEMY_DATABASE_URL = 'postgresql://myuser:mypassword@localhost/TodoApplicationDatabase'

## Explanation
### `create_engine`: This function sets up a connection "engine" to your database, which SQLAlchemy uses to talk to the database.
### `SQLALCHEMY_DATABASE_URL`: This variable should contain your database connection string (for example, `'sqlite:///./test.db'`).
### `connect_args={"check_same_thread": False}`: This argument is specific to SQLite. By default, SQLite connections are single-threaded. Setting `check_same_thread` to `False` allows the connection to be shared across threads, which is useful in web apps (like FastAPI) that handle requests in multiple threads.

engine = create_engine(
    SQLALCHEMY_DATABASE_URL,
    # connect_args={"check_same_thread": False} only for sqlite
)

## Explanation
### `sessionmaker`**: A factory for creating new `Session` objects. Each session manages conversations with the database.
### `autocommit=False`**: Disables automatic commits. You must call `session.commit()` to save changes.
### `autoflush=False`**: Disables automatic flushing of changes to the database before queries. You must call `session.flush()` or `session.commit()` to push changes.
### `bind=engine`**: Associates the session with a specific database engine (connection).

SessionLocal = sessionmaker(
    autocommit=False,
    autoflush=False,
    bind=engine
)

## Explanation
###  `declarative_base()` is a function from SQLAlchemy that returns a new base class.
###  You use this `Base` class as the parent for all your ORM models (Python classes that map to database tables).
###  When you define a model, you inherit from `Base`. SQLAlchemy uses this to keep track of all models and their table definitions.

Base = declarative_base()
