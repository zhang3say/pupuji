@Component
export struct LoginPage {
  onLoginSuccess: () => void = () => {};

  build() {
    Column() {
      Text('登录')
        .fontSize(18)
        .fontColor('#4A3728')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFF8F0')
    .justifyContent(FlexAlign.Center)
  }
}
