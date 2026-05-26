import re

from fastapi import APIRouter, Depends
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from auth.jwt import create_access_token
from auth.schemas import (
    LoginRequest,
    LoginResponse,
    SendCodeRequest,
    SendCodeResponse,
    UserResponse,
)
from auth.sms import send_code, verify_code
from database import get_db
from models.user import User

router = APIRouter(prefix="/api/v1/auth", tags=["auth"])

PHONE_RE = re.compile(r"^1[3-9]\d{9}$")


@router.post("/send-code", response_model=dict)
async def send_verification_code(req: SendCodeRequest):
    if not PHONE_RE.match(req.phone):
        return {"code": 1, "data": None, "message": "手机号格式不正确"}

    ok = await send_code(req.phone)
    if not ok:
        return {"code": 1, "data": None, "message": "请 60 秒后重试"}

    return {"code": 0, "data": None, "message": "验证码已发送"}


@router.post("/login", response_model=dict)
async def login(req: LoginRequest, db: AsyncSession = Depends(get_db)):
    if not PHONE_RE.match(req.phone) or len(req.code) != 6:
        return {"code": 1, "data": None, "message": "手机号或验证码格式不正确"}

    if not await verify_code(req.phone, req.code):
        return {"code": 1, "data": None, "message": "验证码错误或已过期"}

    result = await db.execute(select(User).where(User.phone == req.phone))
    user = result.scalar_one_or_none()

    if user is None:
        user = User(phone=req.phone, nickname=f"噗友{req.phone[-4:]}")
        db.add(user)
        await db.commit()
        await db.refresh(user)

    token = create_access_token(str(user.id))

    return {
        "code": 0,
        "data": {
            "token": token,
            "user": {
                "id": str(user.id),
                "phone": user.phone,
                "nickname": user.nickname,
                "avatar": user.avatar,
                "monthly_salary": float(user.monthly_salary) if user.monthly_salary else None,
                "work_days": float(user.work_days),
                "work_hours": user.work_hours,
            },
        },
        "message": "ok",
    }
