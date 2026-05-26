import { http } from '@kit.NetworkKit';
import { preferences } from '@kit.ArkData';

const BASE_URL = 'http://10.0.2.2:8010/api/v1';
const TOKEN_KEY = 'auth_token';

export class ApiClient {
  static async getToken(): Promise<string> {
    const prefs = await preferences.getPreferences(getContext(), 'pupuji');
    return prefs.get(TOKEN_KEY, '') as Promise<string>;
  }

  static async setToken(token: string): Promise<void> {
    const prefs = await preferences.getPreferences(getContext(), 'pupuji');
    await prefs.put(TOKEN_KEY, token);
    await prefs.flush();
  }

  static async removeToken(): Promise<void> {
    const prefs = await preferences.getPreferences(getContext(), 'pupuji');
    await prefs.delete(TOKEN_KEY);
    await prefs.flush();
  }

  static async request<T>(method: http.RequestMethod, path: string, data?: object): Promise<T> {
    const token = await this.getToken();
    const req = http.createHttp();
    const url = BASE_URL + path;

    const options: http.HttpRequestOptions = {
      method: method,
      header: {
        'Content-Type': 'application/json',
        'X-API-Version': '1',
      },
    };

    if (token) {
      options.header['Authorization'] = `Bearer ${token}`;
    }

    if (data) {
      options.extraData = JSON.stringify(data);
    }

    const resp = await req.request(url, options);
    req.destroy();

    if (resp.responseCode === 401) {
      await this.removeToken();
      throw new Error('Unauthorized');
    }

    const body = JSON.parse(resp.result as string);
    if (body.code !== 0) {
      throw new Error(body.message || 'Request failed');
    }

    return body.data as T;
  }
}
