import { router } from '@kit.ArkUI';

@Component
export struct ProfilePage {
  onLogout: () => void = () => {};

  build() {
    Column() {
      Text('我的')
        .fontSize(18)
        .fontColor('#4A3728')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFF8F0')
    .justifyContent(FlexAlign.Center)
  }
}
