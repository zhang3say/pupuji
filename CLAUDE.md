# CLAUDE.md

This file provides guidance to Claude Code when working in this repository.

## Agent skills

### Issue tracker

GitHub Issues，通过 `gh` CLI 操作。详见 `docs/agents/issue-tracker.md`。

### Triage labels

使用默认标签：`needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`。详见 `docs/agents/triage-labels.md`。

### Domain docs

多上下文布局（Monorepo）：根目录 `CONTEXT-MAP.md` 指向各子项目的 `CONTEXT.md`，ADR 分系统级和上下文级。详见 `docs/agents/domain.md`。
