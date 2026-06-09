# Agent Roadmap Execution

中文 | [English](README_en.md)

`agent-roadmap-execution` 是一个 Codex skill，用于把多会话的 AI 编程工作组织成 milestone 目录、可执行 sprint 文件、验证证据和每个 sprint 的提交记录。

这个 skill 适合需要暂停、恢复和跨会话延续的代码仓库。它把 roadmap 状态保存在仓库内的 Markdown 文件中，并把每个 sprint 视为一个可验证、可恢复的 AI 编程任务切片。

## 内容

- `SKILL.md`：skill 定义和执行工作流。
- `agents/openai.yaml`：Codex skill 列表和默认调用提示使用的 UI 元数据。

## 安装

把下面这句话发给 Codex，让 agent 直接从远程仓库安装：

```txt
请帮我安装这个 Codex skill：https://github.com/liguangsheng/agent-roadmap-execution.git。请检查仓库中的 SKILL.md 和 agents/openai.yaml，把它安装到我的 Codex skills 目录中，并验证安装结果。
```

安装完成后，可以显式调用：

```txt
$agent-roadmap-execution
```

## 新会话恢复

如果项目已经有 `docs/roadmap/`，并且你希望 Codex 从上次暂停的位置继续，建议在新会话的第一句话直接写：

```txt
使用agent-roadmap-execution技能，从 roadmap 的 Resume Point 继续。
```

## 核心约束

- Milestone 表示阶段目标和验收门槛。
- Sprint 表示可执行、可验证、可恢复的任务切片。
- `docs/roadmap/` 只放 roadmap 控制面文档：根 `README.md`、milestone 目录、milestone `README.md` 和 sprint 文件；规格、设计、报告、发布说明、证据附件等放到 `docs/` 其他位置再链接。
- 未来 milestone 在拆分成可执行 sprint 文件前保持 `draft`。
- 执行时从第一个非 `done` sprint 恢复，并优先恢复已有的 `in-progress` sprint。
- 执行过程中不得创建新 milestone，除非用户明确要求扩展、重规划、拆分或创建 roadmap 范围。
- 完成的 sprint 必须记录验证证据，并深度审计目标是否真正完成；如有缺口，保持 `in-progress` 并补齐后重新验证和审计。如果项目是 Git 仓库，还必须在进入下一个 sprint 前完成提交。

## 使用方法

推荐把 roadmap 工作拆成两个 Codex 会话：

- “方向盘”会话：负责和 AI 讨论项目方向，维护 roadmap、milestone 和 sprint 的目标、验收门槛、任务切片、验证方法、Done Criteria 等内容。
- “发动机”会话：负责执行，不再重新讨论路线。可以用 `/goal` 或等价的持续执行方式，让 Codex 按 roadmap 从当前 Resume Point 往前推进。

如果中途发现执行方向跑偏，建议回到“方向盘”会话调整 roadmap：可以把受影响的 milestone 或 sprint 标记为 `blocked`，记录偏差原因和恢复条件；必要时再明确插入一个校正用 milestone。比如 M08 的方向已经不适合继续推进，可以暂停后续 M09，在 M08 后插入 M08.1 来校正路线，再让“发动机”会话从新的 Resume Point 继续。

注意事项：

- 规划和路线调整尽量只在“方向盘”会话中完成，不要让“发动机”会话临场改 roadmap，避免两个会话对项目状态产生分歧。
- “发动机”会话应优先执行当前 `in-progress` sprint；如果没有，则执行第一个非 `done` sprint。
- 每个 sprint 完成前，都要记录验证证据并审计 Goal、Tasks、Done Criteria、变更文件和相关 milestone 验收条件；发现缺口就继续补齐，不能只因为命令通过就进入下一个 sprint。如果项目是 Git 仓库，还应先提交再进入下一个 sprint。
- 建议使用能力较强的模型执行 roadmap 工作，尤其是涉及跨文件修改、长期上下文恢复和验收判断时。
