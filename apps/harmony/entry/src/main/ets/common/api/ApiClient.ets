import { http } from '@kit.NetworkKit';
import { preferences } from '@kit.ArkData';
import { HostContext } from '../store/HostContext';

const BASE_URL = 'http://192.168.10.172:8010/api/v1';
const TOKEN_KEY = 'auth_token';

interface ApiResponseBody {
  code: number;
  message?: string;
  data: ESObject;
}

async function getPrefs(): Promise<preferences.Preferences> {
  try {
    return await preferences.getPreferences(HostContext.get(), 'pupuji');
  } catch (e) {
    throw new Error('Failed to get preferences');
  }
}

export class ApiClient {
  static async getToken(): Promise<string> {
    try {
      const prefs = await getPrefs();
      const token = await prefs.get(TOKEN_KEY, '');
      return token as string;
    } catch (e) {
      return '';
    }
  }

  static async setToken(token: string): Promise<void> {
    try {
      const prefs = await getPrefs();
      await prefs.put(TOKEN_KEY, token);
      await prefs.flush();
    } catch (e) {
      // silently fail
    }
  }

  static async removeToken(): Promise<void> {
    try {
      const prefs = await getPrefs();
      await prefs.delete(TOKEN_KEY);
      await prefs.flush();
    } catch (e) {
      // silently fail
    }
  }

  static async request<T>(method: http.RequestMethod, path: string, data?: object): Promise<T> {
    const token: string = await ApiClient.getToken();
    const req = http.createHttp();
    const url = BASE_URL + path;

    const header: Record<string, string> = {
      'Content-Type': 'application/json',
      'X-API-Version': '1',
    };

    if (token) {
      header['Authorization'] = `Bearer ${token}`;
    }

    const options: http.HttpRequestOptions = {
      method: method,
      header: header,
    };

    if (data) {
      options.extraData = JSON.stringify(data);
    }

    try {
      const resp = await req.request(url, options);
      req.destroy();

      if (resp.responseCode === 401) {
        await ApiClient.removeToken();
        throw new Error('Unauthorized');
      }

      const raw = JSON.parse(resp.result as string) as ApiResponseBody;
      if (raw.code !== 0) {
        throw new Error(raw.message || 'Request failed');
      }

      return raw.data as T;
    } catch (e) {
      req.destroy();
      throw new Error('HTTP request failed');
    }
  }
}
