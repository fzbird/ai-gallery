from sqlalchemy import Table, Column, Integer, ForeignKey
from app.db.base import Base

followers = Table(
    'followers', Base.metadata,
    Column('follower_id', Integer, ForeignKey('user.id', ondelete="CASCADE"), primary_key=True),
    Column('followed_id', Integer, ForeignKey('user.id', ondelete="CASCADE"), primary_key=True)
) 