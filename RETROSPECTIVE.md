# Retrospective

## 007 Android 开源申请增强

### Challenges

- 原仓库已经能运行，但缺少开源项目审查时常看的维护证据，例如 License、CI、贡献说明、路线图、Issue 模板和 Release 材料。
- 早期原型的功能偏薄，如果只补文档，容易显得像临时包装，而不是持续维护的项目。
- Android 构建不能依赖维护者本机的全局 Gradle，需要让外部审查者和 GitHub Actions 能复现构建。

### Solutions

- 生成 Gradle wrapper，让项目可以通过仓库自带脚本执行测试和打包。
- 补充 README、CONTRIBUTING、SECURITY、ROADMAP、Issue 模板、PR 模板和 GitHub Actions。
- 增加更多真实护理字段和本地草稿保存能力，让产品更接近可用的早期 Android 工具。
- 准备 OpenAI Codex for Open Source 申请草稿和达标检查清单，避免申请时夸大项目影响力。

### Learnings

- 对 OpenAI 开源支持申请来说，“能跑”只是底线；更关键的是可审查的维护证据、清楚的项目边界和真实的 maintainer 角色。
- 小项目不应该通过虚构用户或夸大 adoption 来包装，应该诚实展示早期状态和明确路线图。
