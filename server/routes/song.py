import cloudinary
import cloudinary.uploader
from cloudinary.utils import cloudinary_url
from fastapi import APIRouter, UploadFile, File, Form,Depends, status
from sqlalchemy.orm  import Session
from database import get_db
from middleware.auth_middleware import auth_middleware
import uuid
from sqlalchemy.orm import joinedload

from models.favourites import Favourite
from models.song import Song
import os
from pydantic_schemas.favourite_song import FavouriteSong
from dotenv import load_dotenv
load_dotenv()

router = APIRouter(
    prefix='/song',
    tags=['Songs']
)


# Configuration       
cloudinary.config( 
    cloud_name = os.getenv('CLOUD_NAME'), 
    api_key = os.getenv('API_KEY'), 
    api_secret = os.getenv('API_SECRET'),
    secure=True
)


@router.post("/upload", status_code=status.HTTP_201_CREATED)
def upload_song(
    song : UploadFile = File(...), 
    thumbnail : UploadFile = File(...), 
    artist: str = Form(...), 
    song_name: str = Form(...), 
    hex_code: str = Form(...),
    db : Session = Depends(get_db),
    auth_dict = Depends(auth_middleware),
):
    song_id = str(uuid.uuid4())
    song_res = cloudinary.uploader.upload(song.file, resource_type='auto', folder = f'songs/{song_id}')

    thumbnail_res = cloudinary.uploader.upload(thumbnail.file, resource_type='image', folder = f'songs/{song_id}')

    new_song = Song(
        id = song_id,
        song_name = song_name,
        artist = artist,
        hex_code = hex_code.replace(" ","")[:6],
        song_url = song_res['url'],
        thumbnail_url = thumbnail_res['url']
    )
    db.add(new_song)
    db.commit()
    db.refresh(new_song)

    return new_song


@router.get("/list")
def list_songs(db: Session = Depends(get_db), auth_dict = Depends(auth_middleware)):
    songs = db.query(Song).all()
    return songs


@router.post("/favourite")
def favourite_song(song: FavouriteSong,db: Session = Depends(get_db),auth_dict = Depends(auth_middleware)):
    user_id = auth_dict['uid']

    fav_song = db.query(Favourite).filter(Favourite.song_id == song.song_id, Favourite.user_id == user_id).first()

    if fav_song:
        db.delete(fav_song)
        db.commit()
        return {'message': False}
    else:
        new_fav = Favourite(id = str(uuid.uuid4()), song_id = song.song_id, user_id = user_id )
        db.add(new_fav)
        db.commit()
        return {'message': True}
    
@router.get("/list/favourites")
def list_fav_songs(db: Session = Depends(get_db), auth_dict = Depends(auth_middleware)):
    user_id = auth_dict['uid']

    fav_songs = db.query(Favourite).filter(Favourite.user_id == user_id).options(joinedload(Favourite.song)).all()

    return fav_songs