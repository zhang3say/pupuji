import { ApiClient } from '../common/api/ApiClient';

@Component
export struct SalarySetupPage {
  @State monthlySalary: string = '';
  @State workDays: string = '21.75';
  @State workHours: string = '8';
  @State loading: boolean = false;

  get minuteSalary(): string {
    const salary = parseFloat(this.monthlySalary) || 0;
    const days = parseFloat(this.workDays) || 1;
    const hours = parseInt(this.workHours) || 1;
    if (salary <= 0) return '0.00';
    const minute = salary / days / hours / 60;
    return minute.toFixed(2);
  }

  showToast(message: string): void {
    try {
      this.getUIContext().getPromptAction().showToast({ message, duration: 2000 });
    } catch (e) {}
  }

  async save(): Promise<void> {
    const salary = parseFloat(this.monthlySalary);
    if (isNaN(salary) || salary <= 0) {
      this.showToast('请输入有效的月薪');
      return;
    }
    this.loading = true;
    try {
      await ApiClient.request('PUT', '/users/salary', {
        monthly_salary: salary,
        work_days: parseFloat(this.workDays) || 21.75,
        work_hours: parseInt(this.workHours) || 8,
      });
      this.showToast('保存成功');
      this.getUIContext().getRouter().back();
    } catch (e) {
      this.showToast('保存失败');
    } finally { this.loading = false; }
  }

  build() {
    Column() {
      Row() {
        Button('←').fontSize(20).fontColor('#B8956A').backgroundColor('transparent')
          .onClick(() => { this.getUIContext().getRouter().back(); })
        Text('薪资设置').fontSize(18).fontColor('#4A3728').margin({ left: 12 })
      }
      .width('100%').padding(16).margin({ top: 36 })

      Column() {
        this.InputField('月薪 (元)', this.monthlySalary, (v) => { this.monthlySalary = v; }, InputType.NUMBER_DECIMAL)
        this.InputField('每月工作天数', this.workDays, (v) => { this.workDays = v; }, InputType.NUMBER_DECIMAL)
        this.InputField('每日工作小时', this.workHours, (v) => { this.workHours = v; }, InputType.Number)

        Column() {
          Text('每分钟薪资').fontSize(13).fontColor('#C5B8A0')
          Text(`¥${this.minuteSalary}`).fontSize(40).fontWeight(FontWeight.Bold).fontColor('#B8956A').margin({ top: 4 })
          Text(`月薪 ÷ ${this.workDays || '21.75'} 天 ÷ ${this.workHours || '8'} 小时 ÷ 60 分钟`)
            .fontSize(12).fontColor('#C5B8A0').margin({ top: 4 })
        }
        .width('100%').padding(24).margin({ top: 24 }).backgroundColor('#FFF0E0')
        .borderRadius(16).alignItems(HorizontalAlign.Center)

        Button('保存')
          .width('100%').height(52).fontSize(18).fontColor('#FFFFFF')
          .backgroundColor('#B8956A').borderRadius(26).margin({ top: 32 })
          .onClick(() => { this.save(); })
      }
      .width('80%').margin({ top: 32 })
    }
    .width('100%').height('100%').backgroundColor('#FFF8F0')
  }

  @Builder
  InputField(label: string, value: string, onChange: (v: string) => void, type: InputType) {
    Column() {
      Text(label).fontSize(13).fontColor('#4A3728').alignSelf(ItemAlign.Start).margin({ bottom: 6 })
      TextInput({ placeholder: label, text: value })
        .type(type).fontSize(16).height(48).backgroundColor('#FFF0E0').borderRadius(12)
        .padding({ left: 16, right: 16 }).onChange(onChange)
    }
    .width('100%').margin({ bottom: 16 })
  }
}
