import { http } from '@kit.NetworkKit';
import { preferences } from '@kit.ArkData';
import { ApiClient } from '../api/ApiClient';
import { HostContext } from './HostContext';

const ONBOARDING_KEY = 'onboarding_done';

interface LoginData {
  token: string;
  user: UserInfo;
}

interface LoginRequest {
  phone: string;
  code: string;
}

async function getPrefs(): Promise<preferences.Preferences> {
  try {
    return await preferences.getPreferences(HostContext.get(), 'pupuji');
  } catch (e) {
    throw new Error('Failed to get preferences');
  }
}

export class AuthStore {
  token: string = '';
  user: UserInfo | null = null;

  async hydrate(): Promise<void> {
    try {
      const prefs = await getPrefs();
      const saved = await prefs.get('auth_token', '');
      this.token = saved as string;
    } catch (e) {
      this.token = '';
    }
  }

  async isOnboardingDone(): Promise<boolean> {
    try {
      const prefs = await getPrefs();
      const done = await prefs.get(ONBOARDING_KEY, false);
      return done as boolean;
    } catch (e) {
      return false;
    }
  }

  async setOnboardingDone(): Promise<void> {
    try {
      const prefs = await getPrefs();
      await prefs.put(ONBOARDING_KEY, true);
      await prefs.flush();
    } catch (e) {
      // silently fail
    }
  }

  async login(phone: string, code: string): Promise<void> {
    const req: LoginRequest = { phone, code };
    const data = await ApiClient.request<LoginData>(http.RequestMethod.POST, '/auth/login', req);
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
