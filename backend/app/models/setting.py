from sqlalchemy import Column, String, Text
from app.db.base import Base

class Setting(Base):
    """
    A simple key-value store for system settings in the database.
    """
    __tablename__ = 'setting'
    
    key = Column(String(100), primary_key=True, index=True, unique=True)
    value = Column(Text, nullable=True) 