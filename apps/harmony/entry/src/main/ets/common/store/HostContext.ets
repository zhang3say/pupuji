import { common } from '@kit.AbilityKit';

export class HostContext {
  private static _context: common.UIAbilityContext | null = null;

  static init(ctx: common.UIAbilityContext): void {
    HostContext._context = ctx;
  }

  static get(): common.UIAbilityContext {
    if (!HostContext._context) {
      throw new Error('HostContext not initialized');
    }
    return HostContext._context;
  }
}
