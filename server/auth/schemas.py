from pydantic import BaseModel


class SendCodeRequest(BaseModel):
    phone: str


class SendCodeResponse(BaseModel):
    success: bool


class LoginRequest(BaseModel):
    phone: str
    code: str


class LoginResponse(BaseModel):
    token: str
    user: "UserResponse"


class UserResponse(BaseModel):
    id: str
    phone: str
    nickname: str | None
    avatar: str | None
    monthly_salary: float | None
    work_days: float
    work_hours: int
