from pydantic import BaseModel, EmailStr


class SignUp(BaseModel):
    name: str
    email: EmailStr
    password: str

    class Config:
        from_attributes = True  