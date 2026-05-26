# 噗噗记 (Pupuji)

「带薪拉屎」追踪 APP。将如厕时间换算为公司付你的工资，用卡皮巴拉（水豚）泡温泉的可爱意象，主打治愈、佛系、幽默的调性。

> **每次噗噗，都是财富。**

## 技术栈

| 层 | 技术 |
|---|------|
| 鸿蒙端 | ArkTS / ArkUI (HarmonyOS NEXT API 12+) |
| 后端 | FastAPI + SQLAlchemy 2.0 + Alembic |
| 数据库 | PostgreSQL 16 |
| 共享类型 | TypeScript (packages/shared) |
| 项目管理 | pnpm workspace Monorepo |
| Python 依赖 | uv |
| 部署 | Docker Compose |

## 项目结构

```
pupuji/
├── apps/
│   └── harmony/            # 鸿蒙 ArkTS/ArkUI 应用
├── server/                 # FastAPI 后端
├── packages/
│   └── shared/             # 共享 TypeScript 类型定义
├── docs/
│   ├── PRD.md              # 产品需求文档
│   ├── adr/                # 架构决策记录
│   └── agents/             # Agent 技能配置
├── docker-compose.yml      # 本地开发基础设施
├── pnpm-workspace.yaml
├── package.json            # Monorepo 根配置
└── CLAUDE.md
```

## 快速开始

### 环境要求

- **Python** >= 3.11 + [uv](https://docs.astral.sh/uv/)
- **Node.js** >= 18 + [pnpm](https://pnpm.io/)
- **Docker** (PostgreSQL)
- **DevEco Studio** (鸿蒙端，仅 Windows/macOS)

### 1. 启动依赖服务

```bash
# 如果使用已有的 PostgreSQL（如本地 local-postgres 容器）：
docker exec -it local-postgres psql -U testuser -d postgres -c "CREATE DATABASE pupuji;"

# 如果从头开始：
docker compose up -d
```

### 2. 安装依赖

```bash
# 安装 pnpm 依赖
pnpm install

# 安装 Python 依赖
cd server && uv sync
```

### 3. 配置环境变量

```bash
cd server && cp .env.example .env
# 按需修改 .env 中的数据库地址、JWT 密钥等
```

### 4. 数据库迁移

```bash
cd server
uv run alembic revision --autogenerate -m "init"
uv run alembic upgrade head
```

### 5. 启动开发服务器

```bash
# 根目录，一键启动所有服务：
pnpm dev

# 或分别启动：
pnpm dev:server    # FastAPI → http://localhost:8010
```

后端启动后访问 <http://localhost:8010/docs> 查看 API 文档。

### 6. 启动鸿蒙端

用 DevEco Studio 打开 `apps/harmony/` 目录，连接模拟器或真机运行。

## 部署

```bash
# 1. 配置环境变量
cd server && cp .env.example .env
# 编辑 .env 填入生产环境数据库地址和 JWT 密钥

# 2. 一键启动（PostgreSQL + FastAPI）
docker compose up -d --build

# 3. 执行数据库迁移
docker compose exec server alembic upgrade head
```

| 命令 | 说明 |
|------|------|
| `pnpm dev` | 启动所有开发服务 |
| `pnpm dev:server` | 仅启动后端 |
| `pnpm lint` | 运行所有代码检查 |
| `pnpm format` | 格式化所有代码 |
| `cd server && uv run pytest` | 运行后端测试 |
| `cd server && uv run ruff check .` | Python 代码检查 |
| `cd server && uv run alembic revision --autogenerate -m "描述"` | 生成数据库迁移 |
| `cd server && uv run alembic upgrade head` | 执行数据库迁移 |

## API 概览

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/api/v1/auth/send-code` | 发送短信验证码 |
| POST | `/api/v1/auth/login` | 验证码登录 |
| GET | `/api/v1/auth/users/me` | 获取当前用户（需 JWT） |
| PUT | `/api/v1/users/salary` | 设置薪资 |
| POST | `/api/v1/records/start` | 开始计时 |
| POST | `/api/v1/records/{id}/pause` | 暂停计时 |
| POST | `/api/v1/records/{id}/resume` | 继续计时 |
| POST | `/api/v1/records/{id}/finish` | 结束计时 |
| GET | `/api/v1/records/active` | 查询进行中记录 |
| POST | `/api/v1/records/manual` | 手动补录 |
| GET | `/api/v1/records/today-summary` | 今日汇总 |
| GET | `/api/v1/records/history` | 历史记录（分页） |

## 文档

- [产品需求文档 (PRD)](docs/PRD.md)
- [架构决策记录](docs/adr/)
