from typing import Annotated
from sqlalchemy.orm import Session
from fastapi import Depends, APIRouter, HTTPException, Path
from starlette import status


import models
from database import SessionLocal
from .auth import get_current_user

router = APIRouter(
    prefix="/admin",
    tags=["admin"],
)


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

DBDependencyT = Annotated[Session, Depends(get_db)]
UserDependencyT = Annotated[dict[str, str|int], Depends(get_current_user)]

@router.get("/todo", status_code=status.HTTP_200_OK)
async def read_all(user: UserDependencyT, db: DBDependencyT):
    if not user or user.get("role") != "admin":
        raise HTTPException(status_code=401, detail="Authentication XXX Failed")    
    return db.query(models.Todos).filter(models.Todos.owner_id == user["id"]).all()  # 200 OK


@router.delete("/todo/{todo_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_todo(user: UserDependencyT,
                      db: DBDependencyT,
                      todo_id : int = Path(gt=0),
                      ):
    if not user or user.get("role") != "admin":
        raise HTTPException(status_code=401, detail="Authentication Failed")      
    todo_model = db.query(models.Todos).filter(models.Todos.id == todo_id).first()
    if not todo_model:
        raise HTTPException(status_code=404, detail="Todo not found.")

    # This will update the existing record in the database
    db.query(models.Todos).filter(models.Todos.id == todo_id).delete()
    db.commit()