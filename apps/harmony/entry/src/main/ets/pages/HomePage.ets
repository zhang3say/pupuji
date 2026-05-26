import { ApiClient } from '../common/api/ApiClient';
import { promptAction } from '@kit.ArkUI';

interface RecordData {
  id: string;
  start_time: string | null;
  duration_seconds: number;
  amount: number;
  status: string;
}

@Component
export struct HomePage {
  @State isRunning: boolean = false;
  @State isPaused: boolean = false;
  @State recordId: string = '';
  @State elapsedSeconds: number = 0;
  @State amount: number = 0;
  @State loading: boolean = false;
  @State showResult: boolean = false;
  @State resultDuration: number = 0;
  @State resultAmount: number = 0;
  private minuteSalary: number = 0;
  private timer: number = -1;

  aboutToDisappear(): void {
    if (this.timer >= 0) {
      clearInterval(this.timer);
    }
  }

  get displayMinutes(): string {
    const m = Math.floor(this.elapsedSeconds / 60);
    const s = this.elapsedSeconds % 60;
    return `${m.toString().padStart(2, '0')}:${s.toString().padStart(2, '0')}`;
  }

  get displayAmount(): string {
    return (this.amount + this.runningIncrement).toFixed(2);
  }

  get runningIncrement(): number {
    if (!this.isRunning || this.isPaused) return 0;
    if (this.minuteSalary <= 0) return 0;
    return this.minuteSalary * this.elapsedSeconds / 60;
  }

  async checkActive(): Promise<void> {
    try {
      const data = await ApiClient.request<any>('GET', '/records/active');
      if (data && data.id) {
        this.recordId = data.id;
        this.elapsedSeconds = data.duration_seconds || 0;
        this.isPaused = data.start_time === null;
        this.isRunning = true;
        if (!this.isPaused) {
          this.startTick();
        }
      }
    } catch (e) { /* no active record */ }
  }

  startTick(): void {
    if (this.timer >= 0) clearInterval(this.timer);
    this.timer = setInterval(() => {
      this.elapsedSeconds++;
    }, 1000);
  }

  stopTick(): void {
    if (this.timer >= 0) {
      clearInterval(this.timer);
      this.timer = -1;
    }
  }

  async start(): Promise<void> {
    this.loading = true;
    try {
      const data = await ApiClient.request<RecordData>('POST', '/records/start');
      this.recordId = data.id;
      this.elapsedSeconds = 0;
      this.isRunning = true;
      this.isPaused = false;
      this.startTick();
    } catch (e: any) {
      promptAction.showToast({ message: e.message || '开始失败' });
    } finally {
      this.loading = false;
    }
  }

  async pause(): Promise<void> {
    this.loading = true;
    this.stopTick();
    try {
      await ApiClient.request('POST', `/records/${this.recordId}/pause`);
      this.isPaused = true;
    } catch (e) {
      this.startTick();
      promptAction.showToast({ message: '暂停失败' });
    } finally {
      this.loading = false;
    }
  }

  async resume(): Promise<void> {
    this.loading = true;
    try {
      await ApiClient.request('POST', `/records/${this.recordId}/resume`);
      this.isPaused = false;
      this.startTick();
    } catch (e) {
      promptAction.showToast({ message: '继续失败' });
    } finally {
      this.loading = false;
    }
  }

  async finish(): Promise<void> {
    this.loading = true;
    this.stopTick();
    try {
      const data = await ApiClient.request<RecordData>('POST', `/records/${this.recordId}/finish`);
      this.isRunning = false;
      this.isPaused = false;
      this.resultDuration = data.duration_seconds;
      this.resultAmount = data.amount;
      this.showResult = true;
    } catch (e) {
      this.startTick();
      promptAction.showToast({ message: '结束失败' });
    } finally {
      this.loading = false;
    }
  }

  build() {
    Stack() {
      Column() {
        // Header
        Text('噗噗记')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#B8956A')
          .margin({ top: 60 })

        // Timer display
        Column() {
          if (!this.isRunning) {
            Text('🦫')
              .fontSize(80)
              .margin({ bottom: 12 })
            Text('准备好开始噗噗了吗？')
              .fontSize(14)
              .fontColor('#C5B8A0')

            Button('开始噗噗')
              .fontSize(20)
              .fontColor('#FFFFFF')
              .backgroundColor('#B8956A')
              .borderRadius(30)
              .padding({ left: 48, right: 48, top: 14, bottom: 14 })
              .margin({ top: 24 })
              .onClick(() => { this.start(); })
          } else {
            // Running state
            Text(this.displayMinutes)
              .fontSize(56)
              .fontWeight(FontWeight.Bold)
              .fontColor('#4A3728')
              .fontFamily('monospace')

            Text(`+¥${this.displayAmount}`)
              .fontSize(24)
              .fontColor('#B8956A')
              .margin({ top: 4 })

            if (this.isPaused) {
              Text('已暂停')
                .fontSize(14)
                .fontColor('#C5B8A0')
                .margin({ top: 8 })
            }

            // Buttons
            Row({ space: 24 }) {
              if (this.isPaused) {
                Button('继续')
                  .fontSize(16)
                  .fontColor('#FFFFFF')
                  .backgroundColor('#B8956A')
                  .borderRadius(24)
                  .padding({ left: 32, right: 32, top: 10, bottom: 10 })
                  .onClick(() => { this.resume(); })
              } else {
                Button('暂停')
                  .fontSize(16)
                  .fontColor('#B8956A')
                  .backgroundColor('#FFF0E0')
                  .borderRadius(24)
                  .padding({ left: 32, right: 32, top: 10, bottom: 10 })
                  .onClick(() => { this.pause(); })
              }

              Button('结束')
                .fontSize(16)
                .fontColor('#FFFFFF')
                .backgroundColor('#A8D8EA')
                .borderRadius(24)
                .padding({ left: 32, right: 32, top: 10, bottom: 10 })
                .onClick(() => { this.finish(); })
            }
            .margin({ top: 32 })
          }
        }
        .width('85%')
        .padding({ top: 40, bottom: 40 })
        .backgroundColor('#FFFFFF')
        .borderRadius(20)
        .margin({ top: 32 })
        .alignItems(HorizontalAlign.Center)
        .shadow({ radius: 12, color: '#00000010' })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)

      // Result dialog
      if (this.showResult) {
        Column() {
          Column() {
            Text('🎉')
              .fontSize(48)
            Text('本次噗噗')
              .fontSize(18)
              .fontColor('#4A3728')
              .margin({ top: 8 })

            Row() {
              Text(`${Math.floor(this.resultDuration / 60)} 分钟`)
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .fontColor('#B8956A')
            }
            .margin({ top: 12 })

            Text(`为你赚了 ¥${this.resultAmount.toFixed(2)}`)
              .fontSize(16)
              .fontColor('#4A3728')
              .margin({ top: 4 })

            Button('好的')
              .fontSize(16)
              .fontColor('#FFFFFF')
              .backgroundColor('#B8956A')
              .borderRadius(20)
              .padding({ left: 40, right: 40, top: 10, bottom: 10 })
              .margin({ top: 24 })
              .onClick(() => {
                this.showResult = false;
                this.elapsedSeconds = 0;
                this.amount = 0;
              })
          }
          .width('75%')
          .padding(32)
          .backgroundColor('#FFFFFF')
          .borderRadius(20)
          .alignItems(HorizontalAlign.Center)
        }
        .width('100%')
        .height('100%')
        .backgroundColor('#00000050')
        .justifyContent(FlexAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFF8F0')
  }
}
