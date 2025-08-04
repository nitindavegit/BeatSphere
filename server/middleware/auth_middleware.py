from fastapi import Header, HTTPException, status
import jwt
import os
from dotenv import load_dotenv

load_dotenv()

JWT_SECRET_KEY = os.getenv("JWT_SECRET_KEY")

def auth_middleware(x_auth_token = Header()):
    try:
        if not x_auth_token:
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="No auth token, access denied")
        
        verified_token = jwt.decode(x_auth_token,JWT_SECRET_KEY, ['HS256'])

        if not verified_token:
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Token verification failed, authorization denied")
        
        uid = verified_token.get('id')
        return {'uid': uid, 'token' : x_auth_token}
    except jwt.PyJWTError:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Token not valid")