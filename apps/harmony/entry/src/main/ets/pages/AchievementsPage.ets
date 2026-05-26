@Component
export struct AchievementsPage {
  build() {
    Column() {
      Text('成就')
        .fontSize(18)
        .fontColor('#4A3728')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFF8F0')
    .justifyContent(FlexAlign.Center)
  }
}
