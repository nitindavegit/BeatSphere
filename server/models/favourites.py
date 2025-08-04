
from sqlalchemy import TEXT, Column, ForeignKey
from models.base import Base
from sqlalchemy.orm import relationship

class Favourite(Base):
    __tablename__ = 'favourites'

    id = Column(TEXT, primary_key=True)
    song_id = Column(TEXT, ForeignKey("songs.id"))
    user_id = Column(TEXT, ForeignKey("users.id"))

    song = relationship('Song')
    user = relationship('User', back_populates='favourites')
