import { http } from '@kit.NetworkKit';
import { ApiClient } from '../common/api/ApiClient';
import { authStore } from '../common/store/AuthStore';

class ProfileData {
  id: string = '';
  phone: string = '';
  nickname: string | null = null;
  monthly_salary: number | null = null;
  work_days: number = 21.75;
  work_hours: number = 8;
}

@Component
export struct ProfilePage {
  onLogout: () => void = () => {};
  @StorageLink('profileRefreshSignal') @Watch('onRefreshSignal') refreshSignal: number = 0;
  @State user: ProfileData | null = null;

  aboutToAppear(): void {
    this.loadUser();
  }

  onRefreshSignal(): void {
    this.loadUser();
  }

  async loadUser(): Promise<void> {
    try {
      const resp = await ApiClient.request<ProfileData>(http.RequestMethod.GET, '/users/me');
      const data = new ProfileData();
      data.id = resp.id;
      data.phone = resp.phone;
      data.nickname = resp.nickname;
      data.monthly_salary = resp.monthly_salary;
      data.work_days = resp.work_days;
      data.work_hours = resp.work_hours;
      this.user = data;
    } catch (e) {}
  }

  get maskedPhone(): string {
    if (!this.user) return '';
    const p = this.user.phone;
    return `${p.substring(0, 3)}****${p.substring(7)}`;
  }

  get salaryText(): string {
    if (!this.user || this.user.monthly_salary === null) return '未设置';
    return `¥${this.user.monthly_salary.toLocaleString()} / 月`;
  }

  get hourlyRateText(): string {
    if (!this.user || this.user.monthly_salary === null) return '--';
    const hourly = this.user.monthly_salary / (this.user.work_days * this.user.work_hours);
    return `¥${hourly.toFixed(2)}/h`;
  }

  async logout(): Promise<void> {
    await authStore.logout();
    this.onLogout();
  }

  build() {
    Column() {
      Text('我的')
        .fontSize(28).fontWeight(FontWeight.Bold).fontColor('#B8956A')
        .margin({ top: 60, bottom: 24 })

      Column() {
        Text('🦫').fontSize(64)
        Text(this.user?.nickname || '噗友')
          .fontSize(20).fontWeight(FontWeight.Bold).fontColor('#4A3728').margin({ top: 8 })
        Text(this.maskedPhone)
          .fontSize(13).fontColor('#C5B8A0').margin({ top: 4 })
      }
      .width('85%').padding(24).backgroundColor('#FFFFFF')
      .borderRadius(16).margin({ bottom: 16 }).alignItems(HorizontalAlign.Center)
      .shadow({ radius: 8, color: '#00000008' })

      Column() {
        this.InfoItem('薪资设置', this.salaryText, () => {
          this.getUIContext().getRouter().pushUrl({ url: 'pages/SalarySetupPage' });
        }, true)
        Divider().color('#FFF0E0').width('90%')

        this.InfoItem('时薪', this.hourlyRateText, undefined, false)

        Divider().color('#FFF0E0').width('90%')

        this.InfoItem('关于', 'v0.1.0', undefined, false)
      }
      .width('85%').padding({ top: 8, bottom: 8 }).backgroundColor('#FFFFFF')
      .borderRadius(16).margin({ bottom: 16 }).shadow({ radius: 8, color: '#00000008' })

      Button('退出登录')
        .width('85%').height(48).fontSize(16).fontColor('#E88B8B').backgroundColor('#FFFFFF')
        .borderRadius(24).margin({ top: 12 })
        .shadow({ radius: 8, color: '#00000008' })
        .onClick(() => { this.logout(); })
    }
    .width('100%').height('100%').backgroundColor('#FFF8F0').alignItems(HorizontalAlign.Center)
  }

  @Builder
  InfoItem(label: string, value: string, onClick?: () => void, showArrow?: boolean) {
    Row() {
      Text(label).fontSize(15).fontColor('#4A3728')
      Blank()
      Text(value).fontSize(14).fontColor('#C5B8A0')
      if (showArrow) Text(' >').fontSize(14).fontColor('#C5B8A0').margin({ left: 4 })
    }
    .width('100%').height(52).padding({ left: 20, right: 20 })
    .onClick(() => { if (onClick) onClick(); })
  }
}
