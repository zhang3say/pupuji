@Component
export struct HomePage {
  build() {
    Column() {
      Text('噗噗记')
        .fontSize(32)
        .fontWeight(FontWeight.Bold)
        .fontColor('#B8956A')
        .margin({ top: 60 })

      Text('带薪噗噗，快乐翻倍')
        .fontSize(16)
        .fontColor('#4A3728')
        .margin({ top: 8 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFF8F0')
    .justifyContent(FlexAlign.Center)
  }
}
