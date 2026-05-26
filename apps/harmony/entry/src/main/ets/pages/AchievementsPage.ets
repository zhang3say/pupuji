@Component
export struct AchievementsPage {
  build() {
    Column() {
      Text('🏆')
        .fontSize(64)
        .margin({ bottom: 12 })
      Text('敬请期待')
        .fontSize(16)
        .fontColor('#C5B8A0')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFF8F0')
    .justifyContent(FlexAlign.Center)
  }
}
