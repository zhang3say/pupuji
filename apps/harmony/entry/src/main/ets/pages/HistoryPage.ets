import { http } from '@kit.NetworkKit';
import { ApiClient } from '../common/api/ApiClient';

interface RecordItem {
  id: string;
  start_time: string;
  duration_seconds: number;
  amount: number;
  status: string;
  note: string | null;
}

interface HistoryData {
  items: RecordItem[];
  has_more: boolean;
}

interface ManualRecordData {
  start_time: string;
  duration_minutes: number;
  note: string | null;
}

@Component
export struct HistoryPage {
  @State records: RecordItem[] = [];
  @State page: number = 1;
  @State hasMore: boolean = true;
  @State loading: boolean = false;
  @State showForm: boolean = false;
  @State formTime: string = '';
  @State formMinutes: string = '';
  @State formNote: string = '';

  aboutToAppear(): void { this.loadRecords(); }

  showToast(message: string): void {
    try {
      this.getUIContext().getPromptAction().showToast({ message, duration: 2000 });
    } catch (e) {}
  }

  async loadRecords(): Promise<void> {
    if (this.loading || !this.hasMore) return;
    this.loading = true;
    try {
      const data = await ApiClient.request<HistoryData>(http.RequestMethod.GET, `/records/history?page=${this.page}&page_size=20`);
      const items = data.items || [];
      const merged = this.records.concat(items);
      this.records = merged;
      this.hasMore = data.has_more;
      this.page++;
    } catch (e) { this.showToast('加载失败'); }
    finally { this.loading = false; }
  }

  async submitManual(): Promise<void> {
    const mins = parseInt(this.formMinutes);
    if (!this.formTime || isNaN(mins) || mins <= 0) {
      this.showToast('请填写开始时间和时长');
      return;
    }
    try {
      await ApiClient.request<void>(http.RequestMethod.POST, '/records/manual', {
        start_time: this.formTime,
        duration_minutes: mins,
        note: this.formNote || null,
      } as ManualRecordData);
      this.showToast('记录成功');
      this.showForm = false;
      this.formTime = ''; this.formMinutes = ''; this.formNote = '';
      this.page = 1; this.hasMore = true; this.records = [];
      this.loadRecords();
    } catch (e) { this.showToast('记录失败'); }
  }

  formatTime(iso: string): string {
    try { return iso.substring(11, 16); } catch (e) { return ''; }
  }

  formatDate(iso: string): string {
    try { return iso.substring(0, 10); } catch (e) { return ''; }
  }

  formatDuration(seconds: number): string {
    const m = Math.floor(seconds / 60);
    return m >= 60 ? `${Math.floor(m / 60)}h${m % 60}m` : `${m}m`;
  }

  getStatusLabel(status: string): string {
    if (status === 'manual') return '手动记录';
    if (status === 'in_progress') return '进行中';
    return '';
  }

  get groupedRecords(): Array<[string, RecordItem[]]> {
    const map = new Map<string, RecordItem[]>();
    for (const r of this.records) {
      const date = this.formatDate(r.start_time);
      const existing = map.get(date) || [];
      existing.push(r);
      map.set(date, existing);
    }
    return Array.from(map.entries());
  }

  getDateLabel(dateStr: string): string {
    const today = new Date().toISOString().substring(0, 10);
    const yesterday = new Date(Date.now() - 86400000).toISOString().substring(0, 10);
    if (dateStr === today) return '今天';
    if (dateStr === yesterday) return '昨天';
    return dateStr;
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Text('记录')
            .fontSize(28).fontWeight(FontWeight.Bold).fontColor('#B8956A')
          Blank()
          Button('＋')
            .fontSize(28).fontColor('#B8956A').backgroundColor('transparent')
            .onClick(() => { this.showForm = true; })
        }
        .width('85%').margin({ top: 60, bottom: 16 })

        if (this.records.length === 0 && !this.loading) {
          Column() {
            Text('📋').fontSize(48).margin({ bottom: 12 })
            Text('还没有记录').fontSize(16).fontColor('#C5B8A0')
            Text('开始你的第一次噗噗吧').fontSize(14).fontColor('#C5B8A0').margin({ top: 4 })
          }
          .width('100%').margin({ top: 120 }).alignItems(HorizontalAlign.Center)
        } else {
          List({ space: 0 }) {
            ForEach(this.groupedRecords, (group: [string, RecordItem[]]) => {
              ListItem() {
                Column() {
                  Text(this.getDateLabel(group[0]))
                    .fontSize(13).fontColor('#C5B8A0')
                    .padding({ left: 20, top: 16, bottom: 8 })
                    .alignSelf(ItemAlign.Start)

                  ForEach(group[1], (item: RecordItem) => {
                    ListItem() {
                      Row() {
                        Column() {
                          Text(this.formatTime(item.start_time))
                            .fontSize(18).fontWeight(FontWeight.Bold).fontColor('#4A3728')
                          if (this.getStatusLabel(item.status)) {
                            Text(this.getStatusLabel(item.status))
                              .fontSize(10).fontColor('#FFFFFF').backgroundColor('#C5B8A0')
                              .borderRadius(4).padding({ left: 6, right: 6, top: 2, bottom: 2 })
                              .margin({ top: 4 })
                          }
                        }.alignItems(HorizontalAlign.Start)

                        Blank()

                        Column() {
                          Text(this.formatDuration(item.duration_seconds))
                            .fontSize(14).fontColor('#4A3728')
                          Text(`¥${item.amount.toFixed(2)}`)
                            .fontSize(16).fontWeight(FontWeight.Bold).fontColor('#B8956A')
                            .margin({ top: 2 })
                        }.alignItems(HorizontalAlign.End)
                      }
                      .width('100%').padding({ left: 20, right: 20, top: 12, bottom: 12 })
                      .backgroundColor('#FFFFFF')
                    }
                  })
                }
              }
            })

            ListItem() {
              if (this.hasMore) {
                Button('加载更多')
                  .fontSize(14).fontColor('#B8956A').backgroundColor('transparent')
                  .margin({ top: 12, bottom: 24 })
                  .onClick(() => { this.loadRecords(); })
              }
            }
          }
          .layoutWeight(1).width('100%').backgroundColor('#FFF8F0')
        }
      }
      .width('100%').height('100%').backgroundColor('#FFF8F0')

      if (this.showForm) {
        Column() {
          Column() {
            Text('手动记录').fontSize(18).fontColor('#4A3728').margin({ bottom: 20 })

            this.FormField('开始时间', this.formTime, (v) => { this.formTime = v; }, InputType.Normal)
            this.FormField('时长 (分钟)', this.formMinutes, (v) => { this.formMinutes = v; }, InputType.Number)
            this.FormField('备注 (可选)', this.formNote, (v) => { this.formNote = v; }, InputType.Normal)

            Row({ space: 16 }) {
              Button('取消').fontSize(16).fontColor('#C5B8A0').backgroundColor('#FFF0E0')
                .borderRadius(24).padding({ left: 32, right: 32, top: 10, bottom: 10 })
                .layoutWeight(1).onClick(() => { this.showForm = false; })
              Button('保存').fontSize(16).fontColor('#FFFFFF').backgroundColor('#B8956A')
                .borderRadius(24).padding({ left: 32, right: 32, top: 10, bottom: 10 })
                .layoutWeight(1).onClick(() => { this.submitManual(); })
            }.margin({ top: 24 })
          }
          .width('80%').padding(24).backgroundColor('#FFFFFF').borderRadius(16)
        }
        .width('100%').height('100%').backgroundColor('#00000050').justifyContent(FlexAlign.Center)
      }
    }
  }

  @Builder
  FormField(label: string, value: string, onChange: (v: string) => void, type: InputType) {
    Column() {
      Text(label).fontSize(13).fontColor('#4A3728').alignSelf(ItemAlign.Start).margin({ bottom: 6 })
      TextInput({ placeholder: label, text: value })
        .type(type).fontSize(15).height(44).backgroundColor('#FFF8F0').borderRadius(10)
        .padding({ left: 12, right: 12 }).onChange(onChange)
    }.width('100%').margin({ bottom: 14 })
  }
}
