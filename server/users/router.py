from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from auth.dependencies import get_current_user
from database import get_db
from models.user import User
from users.schemas import SalaryUpdateRequest

router = APIRouter(prefix="/api/v1/users", tags=["users"])


@router.get("/me", response_model=dict)
async def get_me(user: User = Depends(get_current_user)):
    return {
        "code": 0,
        "data": {
            "id": str(user.id),
            "phone": user.phone,
            "nickname": user.nickname,
            "avatar": user.avatar,
            "monthly_salary": float(user.monthly_salary) if user.monthly_salary else None,
            "work_days": float(user.work_days),
            "work_hours": user.work_hours,
        },
        "message": "ok",
    }


@router.put("/salary", response_model=dict)
async def update_salary(
    req: SalaryUpdateRequest,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    user.monthly_salary = req.monthly_salary
    user.work_days = req.work_days
    user.work_hours = req.work_hours
    await db.commit()
    await db.refresh(user)

    return {
        "code": 0,
        "data": {
            "id": str(user.id),
            "phone": user.phone,
            "nickname": user.nickname,
            "avatar": user.avatar,
            "monthly_salary": float(user.monthly_salary) if user.monthly_salary else None,
            "work_days": float(user.work_days),
            "work_hours": user.work_hours,
        },
        "message": "ok",
    }
