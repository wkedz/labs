from datetime import datetime, timedelta, timezone
from typing import Annotated
from fastapi import APIRouter, Depends, HTTPException
from fastapi.security import OAuth2PasswordRequestForm, OAuth2PasswordBearer
from pydantic import BaseModel
from sqlalchemy.orm import Session
from passlib.context import CryptContext
from starlette import status
from jose import jwt


import models
from database import SessionLocal

router = APIRouter(
    prefix="/auth",
    tags=["auth"],
)

# openssl rand -hex 32
SECRET_KEY = "92373549ed8562b3e088327efa487c6f7b8e5eb9572e7c2b999e001a70eaac7b"
ALGORITHM = "HS256"

bcrypt_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
oauth2_bearer = OAuth2PasswordBearer(tokenUrl="auth/token")


class CreateUserRequest(BaseModel):
    username: str
    email: str
    first_name: str
    last_name: str
    password: str
    role: str


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


DBDependencyT = Annotated[Session, Depends(get_db)]


def authenticate_user(db: Session, username: str, password: str) -> models.Users | None:
    user = db.query(models.Users).filter(models.Users.username == username).first()
    if not user:
        return None
    if not bcrypt_context.verify(password, str(user.hashed_password)):
        return None
    return user


def create_access_token(username: str, id: int, role:str, expires_delta: timedelta) -> str:
    to_encode: dict[str, str | int  | datetime] = {"sub": username, "id": id, "role": role}
    expires = datetime.now(timezone.utc) + expires_delta
    to_encode.update({"exp": expires})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)  


async def get_current_user(token: Annotated[str, Depends(oauth2_bearer)]) -> dict[str, str|int]:
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        # Same as in create_access_token
        username: str = payload.get("sub")
        id: int = payload.get("id")
        user_role = payload.get("role")
        if username is None or id is None:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail='Could not validate user.',
                )
        return {"username": username, "id": id, "role": user_role}
    except jwt.JWTError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Could not validate user."
            )


@router.post("/", status_code=status.HTTP_201_CREATED)
async def create_user(
    db: DBDependencyT,
    create_user_request: CreateUserRequest
):
    create_user_model = models.Users(
        email=create_user_request.email,
        username=create_user_request.username,
        first_name=create_user_request.first_name,
        last_name=create_user_request.last_name,
        role=create_user_request.role,
        hashed_password=bcrypt_context.hash(create_user_request.password),
        is_active=True
    )
    
    db.add(create_user_model)
    db.commit()


@router.post("/token", response_model=TokenResponse, status_code=status.HTTP_200_OK)
async def login(
    db: DBDependencyT,
    form_data: Annotated[OAuth2PasswordRequestForm, Depends()]
):
    user = authenticate_user(
        db=db,
        username=form_data.username,
        password=form_data.password
    )
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Could not validate user."
            )
    token = create_access_token(
        username=str(user.username),
        id=getattr(user, "id"),
        role=str(user.role),
        expires_delta=timedelta(minutes=30)
    )
    return TokenResponse(
        access_token=token,
        token_type="bearer"
    )