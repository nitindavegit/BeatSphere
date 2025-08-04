import uuid
import bcrypt
from fastapi import HTTPException, Header, status, Depends
from middleware.auth_middleware import auth_middleware
from models.user import User
from pydantic_schemas.user_create import SignUp
from pydantic_schemas.user_login import LogIn
from fastapi import APIRouter
from database import get_db    
from sqlalchemy.orm import Session, joinedload
import jwt
import os
from dotenv import load_dotenv

load_dotenv()

JWT_SECRET_KEY = os.getenv("JWT_SECRET_KEY")


router = APIRouter(
    prefix="/auth",
    tags=['Authentication']
)


@router.post("/signup", status_code=status.HTTP_201_CREATED)
async def signup(user_data: SignUp, db: Session =  Depends(get_db)):

    existing_email = db.query(User).filter(User.email == user_data.email).first()
    if existing_email:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST,detail=f"Email {user_data.email} already exists!")

    hashed_password = bcrypt.hashpw(user_data.password.encode(), bcrypt.gensalt())
    new_user = User(id=str(uuid.uuid4()),name=user_data.name, email=user_data.email, password=hashed_password) 
    db.add(new_user)
    db.commit()
    db.refresh(new_user)

    return new_user

@router.post("/login", status_code=status.HTTP_202_ACCEPTED)
async def login(user_data: LogIn, db : Session= Depends(get_db)):
    user_db = db.query(User).filter(User.email == user_data.email).first()
    if not user_db:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,detail=f"email {user_data.email} not found")
    is_match = bcrypt.checkpw(user_data.password.encode(),user_db.password)
    if not is_match:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED,detail=f"Invalid Credentials")
    
    token = jwt.encode({'id': user_db.id}, JWT_SECRET_KEY)

    return {'token' : token, 'user' : user_db}


@router.get("/")
def current_user_data(db: Session = Depends(get_db), user_dict = Depends(auth_middleware)):
    user = db.query(User).filter(User.id == user_dict['uid']).options(joinedload(User.favourites)).first()

    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")
    
    return user