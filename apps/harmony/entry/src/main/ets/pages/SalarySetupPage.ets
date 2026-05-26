@Component
export struct SalarySetupPage {
  build() {
    Column() {
      Text('薪资设置')
        .fontSize(18)
        .fontColor('#4A3728')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFF8F0')
    .justifyContent(FlexAlign.Center)
  }
}
