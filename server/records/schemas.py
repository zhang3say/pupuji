from pydantic import BaseModel


class RecordResponse(BaseModel):
    id: str
    start_time: str
    end_time: str | None
    duration_seconds: int
    amount: float
    status: str
    note: str | None
