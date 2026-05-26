import uuid
from datetime import datetime, timezone

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession

from auth.dependencies import get_current_user
from database import get_db
from models.record import Record
from models.user import User

from pydantic import BaseModel


class ManualRecordRequest(BaseModel):
    start_time: str  # ISO 8601
    duration_minutes: int
    note: str | None = None


router = APIRouter(prefix="/api/v1/records", tags=["records"])


def calc_minute_salary(user: User) -> float:
    if not user.monthly_salary or user.monthly_salary <= 0:
        return 0
    days = float(user.work_days) or 21.75
    hours = user.work_hours or 8
    return float(user.monthly_salary) / days / hours / 60


async def get_active_record(user_id: uuid.UUID, db: AsyncSession) -> Record | None:
    result = await db.execute(
        select(Record).where(Record.user_id == user_id, Record.status == "in_progress")
    )
    return result.scalar_one_or_none()


def record_to_dict(r: Record) -> dict:
    return {
        "id": str(r.id),
        "start_time": r.start_time.isoformat() if r.start_time else None,
        "end_time": r.end_time.isoformat() if r.end_time else None,
        "duration_seconds": r.duration_seconds,
        "amount": float(r.amount),
        "status": r.status,
        "note": r.note,
    }


@router.post("/start", response_model=dict)
async def start_record(
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    active = await get_active_record(user.id, db)
    if active:
        return {"code": 1, "data": None, "message": "已有进行中的记录"}

    record = Record(
        user_id=user.id,
        start_time=datetime.now(timezone.utc),
        status="in_progress",
    )
    db.add(record)
    await db.commit()
    await db.refresh(record)
    return {"code": 0, "data": record_to_dict(record), "message": "ok"}


@router.get("/active", response_model=dict)
async def get_active(
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    active = await get_active_record(user.id, db)
    if active is None:
        return {"code": 0, "data": None, "message": "ok"}
    return {"code": 0, "data": record_to_dict(active), "message": "ok"}


@router.post("/{record_id}/pause", response_model=dict)
async def pause_record(
    record_id: uuid.UUID,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(Record).where(Record.id == record_id, Record.user_id == user.id)
    )
    record = result.scalar_one_or_none()
    if record is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND)
    if record.status != "in_progress":
        return {"code": 1, "data": None, "message": "记录不是进行中状态"}

    now = datetime.now(timezone.utc)
    elapsed = int((now - record.start_time).total_seconds())
    record.duration_seconds += elapsed
    record.start_time = None
    await db.commit()
    await db.refresh(record)
    return {"code": 0, "data": record_to_dict(record), "message": "ok"}


@router.post("/{record_id}/resume", response_model=dict)
async def resume_record(
    record_id: uuid.UUID,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(Record).where(Record.id == record_id, Record.user_id == user.id)
    )
    record = result.scalar_one_or_none()
    if record is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND)
    if record.status != "in_progress":
        return {"code": 1, "data": None, "message": "记录不是进行中状态"}

    record.start_time = datetime.now(timezone.utc)
    await db.commit()
    return {"code": 0, "data": record_to_dict(record), "message": "ok"}


@router.post("/{record_id}/finish", response_model=dict)
async def finish_record(
    record_id: uuid.UUID,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(Record).where(Record.id == record_id, Record.user_id == user.id)
    )
    record = result.scalar_one_or_none()
    if record is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND)
    if record.status != "in_progress":
        return {"code": 1, "data": None, "message": "记录不是进行中状态"}

    now = datetime.now(timezone.utc)
    additional = 0
    if record.start_time:
        additional = int((now - record.start_time).total_seconds())

    record.duration_seconds += additional
    record.end_time = now
    record.status = "finished"

    minute_salary = calc_minute_salary(user)
    record.amount = round(minute_salary * record.duration_seconds / 60, 2)

    await db.commit()
    await db.refresh(record)
    return {"code": 0, "data": record_to_dict(record), "message": "ok"}


@router.post("/manual", response_model=dict)
async def create_manual_record(
    req: ManualRecordRequest,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    try:
        start = datetime.fromisoformat(req.start_time)
    except ValueError:
        return {"code": 1, "data": None, "message": "开始时间格式不正确"}

    now = datetime.now(timezone.utc)
    if start > now:
        return {"code": 1, "data": None, "message": "开始时间不能超过当前时间"}

    if req.duration_minutes <= 0 or req.duration_minutes > 1440:
        return {"code": 1, "data": None, "message": "时长必须在 1-1440 分钟之间"}

    duration = req.duration_minutes * 60
    minute_salary = calc_minute_salary(user)
    amount = round(minute_salary * duration / 60, 2)

    record = Record(
        user_id=user.id,
        start_time=start,
        end_time=None,
        duration_seconds=duration,
        amount=amount,
        status="manual",
        note=req.note,
    )
    db.add(record)
    await db.commit()
    await db.refresh(record)
    return {"code": 0, "data": record_to_dict(record), "message": "ok"}


@router.get("/today-summary", response_model=dict)
async def today_summary(
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    today_start = datetime.now(timezone.utc).replace(hour=0, minute=0, second=0, microsecond=0)

    result = await db.execute(
        select(
            func.count(Record.id),
            func.coalesce(func.sum(Record.duration_seconds), 0),
            func.coalesce(func.sum(Record.amount), 0),
        ).where(
            Record.user_id == user.id,
            Record.start_time >= today_start,
            Record.status.in_(["finished", "manual"]),
        )
    )
    count, total_seconds, total_amount = result.one()

    return {
        "code": 0,
        "data": {
            "count": count,
            "total_duration_seconds": int(total_seconds),
            "total_amount": float(total_amount),
            "company_paid": float(total_amount),
        },
        "message": "ok",
    }


@router.get("/history", response_model=dict)
async def history(
    page: int = 1,
    page_size: int = 20,
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    offset = (page - 1) * page_size
    result = await db.execute(
        select(Record)
        .where(Record.user_id == user.id)
        .order_by(Record.start_time.desc())
        .offset(offset)
        .limit(page_size)
    )
    records = result.scalars().all()

    total_result = await db.execute(
        select(func.count(Record.id)).where(Record.user_id == user.id)
    )
    total = total_result.scalar()

    return {
        "code": 0,
        "data": {
            "items": [record_to_dict(r) for r in records],
            "total": total,
            "page": page,
            "page_size": page_size,
            "has_more": offset + page_size < total,
        },
        "message": "ok",
    }
