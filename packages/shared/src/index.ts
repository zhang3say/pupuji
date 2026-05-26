export interface ApiResponse<T = unknown> {
  code: number;
  data: T;
  message: string;
}

export interface User {
  id: string;
  phone: string;
  nickname: string | null;
  avatar: string | null;
  monthly_salary: number | null;
  work_days: number;
  work_hours: number;
}

export type RecordStatus = 'in_progress' | 'finished' | 'manual';

export interface Record {
  id: string;
  start_time: string;
  end_time: string | null;
  duration_seconds: number;
  amount: number;
  status: RecordStatus;
  note: string | null;
}

export interface TodaySummary {
  count: number;
  total_duration_seconds: number;
  total_amount: number;
}

export interface SalaryInput {
  monthly_salary: number;
  work_days?: number;
  work_hours?: number;
}

export interface ManualRecordInput {
  start_time: string;
  duration_minutes: number;
  note?: string;
}

export const MINUTE_SALARY_FORMULA = '月薪 ÷ 工作天数 ÷ 工作小时数 ÷ 60';
