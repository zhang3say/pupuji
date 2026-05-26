import logging
import random

from config import settings
from auth.redis import redis_client

logger = logging.getLogger(__name__)


def generate_code() -> str:
    return "".join(random.choices("0123456789", k=settings.SMS_CODE_LENGTH))


async def send_code(phone: str) -> bool:
    resent_key = f"sms:resent:{phone}"
    if await redis_client.exists(resent_key):
        return False

    code = generate_code()
    code_key = f"sms:code:{phone}"
    await redis_client.setex(code_key, settings.SMS_CODE_TTL, code)
    await redis_client.setex(resent_key, settings.SMS_RESEND_SECONDS, "1")
    logger.info(f"[SMS] phone={phone} code={code}")
    return True


async def verify_code(phone: str, code: str) -> bool:
    code_key = f"sms:code:{phone}"
    stored = await redis_client.get(code_key)
    if stored is None or stored != code:
        return False
    await redis_client.delete(code_key)
    return True
