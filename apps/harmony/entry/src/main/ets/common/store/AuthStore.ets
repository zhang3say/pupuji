import { preferences } from '@kit.ArkData';
import { ApiClient } from '../api/ApiClient';

const ONBOARDING_KEY = 'onboarding_done';

export class AuthStore {
  token: string = '';
  user: UserInfo | null = null;

  async hydrate(): Promise<void> {
    const prefs = await preferences.getPreferences(getContext(), 'pupuji');
    this.token = prefs.get('auth_token', '') as string;
  }

  async isOnboardingDone(): Promise<boolean> {
    const prefs = await preferences.getPreferences(getContext(), 'pupuji');
    return prefs.get(ONBOARDING_KEY, false) as Promise<boolean>;
  }

  async setOnboardingDone(): Promise<void> {
    const prefs = await preferences.getPreferences(getContext(), 'pupuji');
    await prefs.put(ONBOARDING_KEY, true);
    await prefs.flush();
  }

  async login(phone: string, code: string): Promise<void> {
    const data = await ApiClient.request<{ token: string; user: UserInfo }>('POST', '/auth/login', {
      phone,
      code,
    });
    this.token = data.token;
    this.user = data.user;
    await ApiClient.setToken(data.token);
  }

  async logout(): Promise<void> {
    this.token = '';
    this.user = null;
    await ApiClient.removeToken();
  }

  get isLoggedIn(): boolean {
    return this.token.length > 0;
  }
}

export interface UserInfo {
  id: string;
  phone: string;
  nickname: string | null;
  monthly_salary: number | null;
  work_days: number;
  work_hours: number;
}

export const authStore = new AuthStore();
