from pydantic import BaseModel


class SalaryUpdateRequest(BaseModel):
    monthly_salary: float
    work_days: float = 21.75
    work_hours: int = 8
