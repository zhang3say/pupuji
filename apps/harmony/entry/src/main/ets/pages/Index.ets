import { authStore } from '../common/store/AuthStore';

@Entry
@Component
struct Index {
  @State currentTabIndex: number = 0;
  @State isLoggedIn: boolean = false;
  @State showOnboarding: boolean = true;

  private tabsController = new TabsController();

  async aboutToAppear(): Promise<void> {
    await authStore.hydrate();
    this.isLoggedIn = authStore.isLoggedIn;
    if (this.isLoggedIn) {
      this.showOnboarding = false;
    } else {
      const done = await authStore.isOnboardingDone();
      this.showOnboarding = !done;
    }
  }

  build() {
    if (!this.isLoggedIn) {
      if (this.showOnboarding) {
        Navigation() {
          OnboardingPage({ onComplete: () => {
            authStore.setOnboardingDone();
            this.showOnboarding = false;
          } })
        }
      } else {
        Navigation() {
          LoginPage({ onLoginSuccess: () => {
            this.isLoggedIn = true;
          } })
        }
      }
    } else {
      Tabs({ barPosition: BarPosition.End, controller: this.tabsController }) {
        TabContent() { HomePage() }
          .tabBar('噗噗')
        TabContent() { HistoryPage() }
          .tabBar('记录')
        TabContent() { AchievementsPage() }
          .tabBar('成就')
        TabContent() { ProfilePage({ onLogout: () => { this.isLoggedIn = false } }) }
          .tabBar('我的')
      }
      .barHeight(56)
      .backgroundColor('#FFF8F0')
      .width('100%')
      .height('100%')
    }
  }
}
