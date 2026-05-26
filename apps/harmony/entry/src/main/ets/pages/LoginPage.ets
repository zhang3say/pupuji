import { ApiClient } from '../common/api/ApiClient';
import { authStore } from '../common/store/AuthStore';

@Component
export struct LoginPage {
  onLoginSuccess: () => void = () => {};

  @State phone: string = '';
  @State code: string = '';
  @State countdown: number = 0;
  @State loading: boolean = false;
  private timer: number = -1;

  aboutToDisappear(): void {
    if (this.timer >= 0) clearInterval(this.timer);
  }

  startCountdown(): void {
    this.countdown = 60;
    this.timer = setInterval(() => {
      this.countdown--;
      if (this.countdown <= 0) {
        clearInterval(this.timer);
        this.timer = -1;
      }
    }, 1000);
  }

  showToast(message: string): void {
    try {
      this.getUIContext().getPromptAction().showToast({ message, duration: 2000 });
    } catch (e) {}
  }

  async sendCode(): Promise<void> {
    if (this.countdown > 0) return;
    if (this.phone.length !== 11) {
      this.showToast('请输入正确的手机号');
      return;
    }
    this.loading = true;
    try {
      await ApiClient.request('POST', '/auth/send-code', { phone: this.phone });
      this.startCountdown();
      this.showToast('验证码已发送');
    } catch (e) {
      this.showToast('发送失败，请重试');
    } finally { this.loading = false; }
  }

  async doLogin(): Promise<void> {
    if (this.phone.length !== 11) {
      this.showToast('请输入正确的手机号');
      return;
    }
    if (this.code.length !== 6) {
      this.showToast('请输入6位验证码');
      return;
    }
    this.loading = true;
    try {
      await authStore.login(this.phone, this.code);
      this.onLoginSuccess();
    } catch (e) {
      this.showToast('登录失败，请检查验证码');
    } finally { this.loading = false; }
  }

  build() {
    Column() {
      Column() {
        Text('🦫').fontSize(64)
        Text('噗噗记').fontSize(28).fontWeight(FontWeight.Bold).fontColor('#B8956A').margin({ top: 12 })
        Text('带薪噗噗，快乐翻倍').fontSize(14).fontColor('#C5B8A0').margin({ top: 4 })
      }.margin({ top: 80 })

      Column() {
        Row() {
          Text('+86').fontSize(16).fontColor('#4A3728').margin({ right: 12 })
          TextInput({ placeholder: '请输入手机号', text: this.phone })
            .maxLength(11).type(InputType.Number).fontSize(16).layoutWeight(1)
            .backgroundColor('transparent').onChange((value: string) => { this.phone = value; })
        }
        .width('100%').padding({ left: 16, right: 16 }).height(52)
        .backgroundColor('#FFF0E0').borderRadius(12)

        Row() {
          TextInput({ placeholder: '验证码', text: this.code })
            .maxLength(6).type(InputType.Number).fontSize(16).layoutWeight(1)
            .backgroundColor('transparent').onChange((value: string) => { this.code = value; })
          Button(this.countdown > 0 ? `${this.countdown}s` : '获取验证码')
            .fontSize(13).fontColor(this.countdown > 0 ? '#C5B8A0' : '#B8956A')
            .backgroundColor('transparent').enabled(this.countdown === 0)
            .onClick(() => { this.sendCode(); })
        }
        .width('100%').padding({ left: 16, right: 4 }).height(52)
        .backgroundColor('#FFF0E0').borderRadius(12)

        Button('登录')
          .width('100%').height(52).fontSize(18).fontColor('#FFFFFF')
          .backgroundColor('#B8956A').borderRadius(26).margin({ top: 32 })
          .onClick(() => { this.doLogin(); })
      }
      .width('80%').margin({ top: 48 })
    }
    .width('100%').height('100%').backgroundColor('#FFF8F0')
  }
}
