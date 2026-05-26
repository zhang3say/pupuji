import logging
import random
from datetime import datetime, timedelta, timezone

from sqlalchemy import delete, select
from sqlalchemy.ext.asyncio import AsyncSession

from config import settings
from database import async_session
from models.verification_code import VerificationCode

logger = logging.getLogger(__name__)


def generate_code() -> str:
    return "".join(random.choices("0123456789", k=settings.SMS_CODE_LENGTH))


async def send_code(phone: str) -> bool:
    async with async_session() as db:
        # Check rate limit: any code sent to this phone in last 60s?
        cutoff = datetime.now(timezone.utc) - timedelta(seconds=settings.SMS_RESEND_SECONDS)
        result = await db.execute(
            select(VerificationCode).where(
                VerificationCode.phone == phone,
                VerificationCode.created_at > cutoff,
            )
        )
        if result.scalar_one_or_none() is not None:
            return False

        # Delete old codes for this phone
        await db.execute(delete(VerificationCode).where(VerificationCode.phone == phone))

        code = generate_code()
        expires_at = datetime.now(timezone.utc) + timedelta(seconds=settings.SMS_CODE_TTL)
        vc = VerificationCode(phone=phone, code=code, expires_at=expires_at)
        db.add(vc)
        await db.commit()

        logger.info(f"[SMS] phone={phone} code={code}")
        return True


async def verify_code(phone: str, code: str) -> bool:
    async with async_session() as db:
        now = datetime.now(timezone.utc)
        result = await db.execute(
            select(VerificationCode).where(
                VerificationCode.phone == phone,
                VerificationCode.code == code,
                VerificationCode.expires_at > now,
            )
        )
        vc = result.scalar_one_or_none()
        if vc is None:
            return False

        await db.delete(vc)
        await db.commit()
        return True
