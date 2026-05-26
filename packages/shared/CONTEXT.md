# 噗噗记共享层 — 领域词汇

## 类型

- **ApiResponse\<T\>**：统一响应格式 `{ code, data, message }`
- **User**：用户信息结构（id, phone, nickname, avatar, monthly_salary, work_days, work_hours）
- **Record**：如厕记录结构（id, start_time, end_time, duration_seconds, amount, status, note）
- **RecordStatus**：`'in_progress' | 'finished' | 'manual'`
- **TodaySummary**：今日汇总（count, total_duration_seconds, total_amount）
- **SalaryInput**：薪资输入（monthly_salary, work_days?, work_hours?）
- **ManualRecordInput**：手动补录输入（start_time, duration_minutes, note?）

## 公式常量

- **MINUTE_SALARY_FORMULA**：`月薪 ÷ 工作天数 ÷ 工作小时数 ÷ 60`
