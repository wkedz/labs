from fastapi import FastAPI
import models
from database import engine
from routers import auth, todos, admin,users


app = FastAPI()

##
# This code creates all tables defined in your SQLAlchemy models in the connected database. 
# It's typically used during app setup to ensure the database schema matches your Python models.

##Explanation:
###`models.Base` is the base class for your ORM models, usually created with `declarative_base()`.
###`.metadata` holds information about all the tables and schema you've defined as Python classes.
###`.create_all(bind=engine)` tells SQLAlchemy to create all tables in the database (if they don't already exist), using the provided `engine` (which defines your database connection).

models.Base.metadata.create_all(bind=engine)

@app.get("/healthcheck")
def healthcheck():
    """
    Health check endpoint to verify the API is running.
    """
    return {"status": "ok"}

app.include_router(auth.router)
app.include_router(todos.router)
app.include_router(admin.router)
app.include_router(users.router)

