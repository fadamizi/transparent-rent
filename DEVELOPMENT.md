# 本地开发

当前为架构骨架：Web 仅有占位首页，Verifier 仅开放健康检查；四个业务页面、认证、Canvas 打码、OCR、产权核验、支付和电子签约尚未接入。

1. 根目录执行 `npm ci`。
2. 复制 `.env.example` 为 `.env` 并填写 Supabase 参数，不提交真实密钥。
3. Prisma 命令需要导出 `DATABASE_URL` 和 `DIRECT_URL`，或在 `apps/web/.env` 中配置。
4. 执行 `npm run db:validate` 检查 Schema，`npm run dev` 启动 Web。
5. 根目录配置 `.env` 后执行 `docker compose up --build`，访问 http://localhost:3000。Verifier 与 Redis 仅在容器内网开放。

数据库由 Supabase 提供；PostGIS 扩展、空间索引、RLS 与 Storage 私有策略在后续迁移落实。

固定服务费以分存储为 19900（¥199），初始 SQL 迁移已加入 CHECK 约束。房源发布前仍需检查产权验真状态；复合外键保证核验人与房东一致。

IQR 原型按用户原文保留，deviation 相对历史均值计算；中位数报价测算仍待实现。接入前需校验正数租金并统一户型、面积等可比口径。产证哈希用于匹配或去重，真实性仍需权威渠道或人工核验。

安装后可通过 `npx prisma migrate deploy --schema apps/web/prisma/schema.prisma` 应用初始迁移。依赖覆盖将 PostCSS 与 deepmerge-ts 固定在已修复安全问题的版本范围，升级 Prisma 时应复核这些覆盖。
