from typing import Optional
from pydantic import BaseModel

class Token(BaseModel):
    access_token: str
    token_type: str
 
class TokenData(BaseModel):
    username: Optional[str] = None 

class TokenPayload(BaseModel):
    sub: Optional[str] = None
    exp: Optional[int] = None
    type: str = "access"

class Message(BaseModel):
    message: str
