from pydantic import BaseModel

class Token(BaseModel):
    access_token: str
    token_type: str
 
class TokenData(BaseModel):
    username: str | None = None 

class TokenPayload(BaseModel):
    sub: str = None
    exp: int = None
    type: str = "access"

class Message(BaseModel):
    message: str
