@Component
export struct OnboardingPage {
  onComplete: () => void = () => {};

  build() {
    Swiper() {
      Column() {
        Text('💩').fontSize(80)
        Text('欢迎来到噗噗记').fontSize(24).fontColor('#B8956A').margin({ top: 20 })
        Text('带薪噗噗，快乐翻倍').fontSize(16).fontColor('#4A3728').margin({ top: 8 })
      }
      .backgroundColor('#FFF8F0').justifyContent(FlexAlign.Center)

      Column() {
        Text('🦫').fontSize(80)
        Text('卡皮巴拉陪你').fontSize(24).fontColor('#B8956A').margin({ top: 20 })
        Text('泡温泉式蹲坑体验').fontSize(16).fontColor('#4A3728').margin({ top: 8 })
      }
      .backgroundColor('#FFF8F0').justifyContent(FlexAlign.Center)

      Column() {
        Text('💰').fontSize(80)
        Text('开始噗噗吧').fontSize(24).fontColor('#B8956A').margin({ top: 20 })
        Text('每次噗噗，都是财富').fontSize(16).fontColor('#4A3728').margin({ top: 8 })
        Button('开始使用')
          .fontSize(18).backgroundColor('#B8956A').borderRadius(24)
          .padding({ left: 48, right: 48, top: 12, bottom: 12 })
          .margin({ top: 40 }).onClick(() => { this.onComplete(); })
      }
      .backgroundColor('#FFF8F0').justifyContent(FlexAlign.Center)
    }
    .indicator(true).loop(false)
    .width('100%').height('100%')
  }
}
