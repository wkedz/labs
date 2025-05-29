from typing import Annotated
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session
from fastapi import Depends, APIRouter, HTTPException, Path
from starlette import status


import models
from database import SessionLocal
from .auth import get_current_user

router = APIRouter(
    tags=["todos"],
)


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

DBDependencyT = Annotated[Session, Depends(get_db)]
UserDependencyT = Annotated[dict[str, str|int], Depends(get_current_user)]

class TodoRequest(BaseModel):
    title: str = Field(min_length=3)
    description: str = Field(min_length=3, max_length=10)
    priority: int = Field(gt=0, le=6)
    complete: bool


@router.get("/", status_code=status.HTTP_200_OK)
async def read_all(user: UserDependencyT, db: DBDependencyT):
    if not user:
        raise HTTPException(status_code=401, detail="Authentication Failed")    
    return db.query(models.Todos).filter(models.Todos.owner_id == user["id"]).all()  # 200 OK


@router.get("/todo/{todo_id}", status_code=status.HTTP_200_OK)
async def read_todo(user: UserDependencyT, db: DBDependencyT, todo_id : int = Path(gt=0)):
    if not user:
        raise HTTPException(status_code=401, detail="Authentication Failed")    
    todo_model = db.query(models.Todos)\
                   .filter(models.Todos.id == todo_id)\
                   .filter(models.Todos.owner_id == user.get("id"))\
                   .first()
    if todo_model:
        return todo_model
    raise HTTPException(status_code=404, detail="Todo not found.")  # 404 Not Found


@router.post("/todo", status_code=status.HTTP_201_CREATED)
async def create_todo(user: UserDependencyT, db: DBDependencyT, todo: TodoRequest):
    if not user:
        raise HTTPException(status_code=401, detail="Authentication Failed")
    todo_model = models.Todos(**todo.model_dump(), owner_id=user.get("id"))
    db.add(todo_model)
    db.commit()


@router.put("/todo/{todo_id}", status_code=status.HTTP_204_NO_CONTENT)
async def update_todo(user: UserDependencyT,
                      db: DBDependencyT,
                      todo: TodoRequest,
                      todo_id : int = Path(gt=0),
                      ):
    if not user:
        raise HTTPException(status_code=401, detail="Authentication Failed")    
    todo_model = db.query(models.Todos)\
                   .filter(models.Todos.id == todo_id)\
                   .filter(models.Todos.owner_id == user.get("id"))\
                   .first()
    if not todo_model:
        raise HTTPException(status_code=404, detail="Todo not found.")

    # We must update the fields of the existing todo_model with the new values
    new_todo_model =  models.Todos(**todo.model_dump())
    todo_model.title = new_todo_model.title
    todo_model.description = new_todo_model.description
    todo_model.priority = new_todo_model.priority
    todo_model.complete = new_todo_model.complete

    # This will update the existing record in the database
    db.add(todo_model)
    db.commit()


@router.delete("/todo/{todo_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_todo(user: UserDependencyT,
                      db: DBDependencyT,
                      todo_id : int = Path(gt=0),
                      ):
    if not user:
        raise HTTPException(status_code=401, detail="Authentication Failed")      
    todo_model = db.query(models.Todos).filter(models.Todos.id == todo_id).first()
    if not todo_model:
        raise HTTPException(status_code=404, detail="Todo not found.")

    # This will update the existing record in the database
    db.query(models.Todos).filter(models.Todos.id == todo_id).delete()
    db.commit()