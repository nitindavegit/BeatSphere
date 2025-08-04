from pydantic import BaseModel, EmailStr


class LogIn(BaseModel):
    email: EmailStr
    password: str

    class Config:
        from_attributes = True