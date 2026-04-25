from pydantic import BaseModel, EmailStr
from typing import Optional, List, Any
from datetime import datetime
from app.models.models import JobStatus

# User Schemas
class UserBase(BaseModel):
    email: Optional[EmailStr] = None
    full_name: Optional[str] = None

class UserCreate(UserBase):
    email: EmailStr
    password: str

class UserUpdate(UserBase):
    password: Optional[str] = None

class UserInDBBase(UserBase):
    id: Optional[int] = None

    class Config:
        from_attributes = True

class User(UserInDBBase):
    pass

class Token(BaseModel):
    access_token: str
    token_type: str

class TokenPayload(BaseModel):
    sub: Optional[int] = None

# Job Schemas
class JobBase(BaseModel):
    title: str
    parameters: Optional[Any] = None

class JobCreate(JobBase):
    pass

class JobUpdate(JobBase):
    status: Optional[JobStatus] = None

class Job(JobBase):
    id: int
    status: JobStatus
    created_at: datetime
    started_at: Optional[datetime] = None
    finished_at: Optional[datetime] = None
    owner_id: int

    class Config:
        from_attributes = True

class StorageUploadRequest(BaseModel):
    filename: str
