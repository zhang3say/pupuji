@Component
export struct HistoryPage {
  build() {
    Column() {
      Text('历史记录')
        .fontSize(18)
        .fontColor('#4A3728')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFF8F0')
    .justifyContent(FlexAlign.Center)
  }
}
