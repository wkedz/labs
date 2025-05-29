from typing import Annotated
from pydantic import BaseModel
from sqlalchemy.orm import Session
from fastapi import Depends, APIRouter, HTTPException, Query
from starlette import status


import models
from database import SessionLocal
from .auth import get_current_user,bcrypt_context

router = APIRouter(
    prefix="/users",
    tags=["users"],
)


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

DBDependencyT = Annotated[Session, Depends(get_db)]
UserDependencyT = Annotated[dict[str, str|int], Depends(get_current_user)]


class UserVerification(BaseModel):
    password : str
    new_password : str

@router.get("/get_user", status_code=status.HTTP_200_OK)
async def get_user(user: UserDependencyT, db: DBDependencyT):
    if not user:
        raise HTTPException(status_code=401, detail='Authentication Failed')
    return db.query(models.Users).filter(models.Users.id == user.get('id')).first()

@router.put("/password", status_code=status.HTTP_204_NO_CONTENT)
async def change_password(user: UserDependencyT, db: DBDependencyT,
                          user_verification: UserVerification):
    if user is None:
        raise HTTPException(status_code=401, detail='Authentication Failed')
    user_model = db.query(models.Users).filter(models.Users.id == user.get('id')).first()

    if not bcrypt_context.verify(user_verification.password, user_model.hashed_password):
        raise HTTPException(status_code=401, detail='Error on password change')
    user_model.hashed_password = bcrypt_context.hash(user_verification.new_password)
    db.add(user_model)
    db.commit()