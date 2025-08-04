from fastapi import FastAPI
from routes import auth, song
from models.base import Base
from database import engine
app = FastAPI()

app.include_router(auth.router)
app.include_router(song.router)
Base.metadata.create_all(engine)
    