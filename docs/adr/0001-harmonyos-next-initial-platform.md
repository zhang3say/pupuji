# ADR-0001: 鸿蒙 NEXT 作为首发平台

**日期**: 2026-05-26

**状态**: 已采纳

## 背景

噗噗记 MVP 需要选择一个首发平台。原 PRD 规划 React Native (iOS) 首发，鸿蒙留到 P2。经过重新评估，决定优先投入鸿蒙 NEXT 生态。

## 决策

初期**仅实现鸿蒙 NEXT (API 12+)**，使用 ArkTS + ArkUI 原生开发。iOS/Android 端延后至 Phase 3。

## 考虑过的替代方案

| 方案 | 优点 | 缺点 |
|------|------|------|
| React Native (iOS 首发) | 成熟生态、一次编码跨端、Zustand/React Navigation 等库丰富 | 与鸿蒙生态不兼容，后续仍需独立开发鸿蒙端 |
| **鸿蒙 NEXT 原生 (采纳)** | 原生体验最佳、DevEco Studio 工具链完善、ArkTS 与 TypeScript 共享类型定义 | 用户基数不如 iOS，第三方库生态较弱 |
| Flutter | 跨端包括鸿蒙(WIP) | 鸿蒙支持不成熟 |

## 影响

- 项目结构简化为 `apps/harmony/` + `server/` + `packages/shared/`
- `packages/shared/` 的 TypeScript 类型可被 ArkTS（TS 超集）复用
- MVP 阶段不涉及 React Native / iOS 任何代码
- 后续加 iOS/Android 时需独立开发，成本更高，但这在 Phase 3 才重新评估
