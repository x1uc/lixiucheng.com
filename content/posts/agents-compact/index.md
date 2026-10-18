---
title: "不同 Agent 上下文压缩的实现对比"
date: 2026-10-18
description: "从压缩时机、提示词和代码阅读体验，对比 Crush、OpenCode 和 Pi 的上下文压缩实现。"
images:
  - agents-compact/cover.png
---

## 基本概念

- Step：一次步骤执行（例如思考、工具调用）
- Turn：一轮对话

一轮对话：以排查日志为例

```text
User Message
    ↓
Step 1: LLM 分析问题
    ↓
Step 2: 调用 search_logs
    ↓
Step 3: LLM 阅读日志并发现数据库超时
    ↓
Step 4: 调用 query_metrics
    ↓
Step 5: LLM 综合结果
    ↓
Assistant Message
```

## [Crush](https://github.com/charmbracelet/crush) #8b2b2857

Crush 的实现最为简单，基本没处理 corner case

### 时机

- 每个 Step 执行之后判断上下文是否超过阈值（一般为窗口大小的 80%）

### 提示词摘要

1. 当前状态（当前任务、完成了什么、现在正在干什么、剩余的步骤）
2. 文件改动相关信息
3. 技术相关上下文（项目架构、编码规则、环境信息、失败执行的命令及原因）
4. 策略和方法（采用的解决方案、选择该方法的原因、当前已经知道的关键信息，踩的坑、关键的信息、任务风险和阻碍）
5. 精确的下一步（要具体的执行步骤，而不是泛泛之谈）
6. 生成约束（像在任务中途向接手的队友做简报一样写作，包含他们无需提问即可继续工作所需的一切内容，不要使用表情符号、务必详尽，关键信息值得消耗上下文进行保留）

```md
You are summarizing a conversation to preserve context for continuing work later.

**Critical**: This summary will be the ONLY context available when the conversation resumes. Assume all previous messages will be lost. Be thorough.

**Required sections**:

## Current State

- What task is being worked on (exact user request)
- Current progress and what's been completed
- What's being worked on right now (incomplete work)
- What remains to be done (specific next steps, not vague)

## Files & Changes

- Files that were modified (with brief description of changes)
- Files that were read/analyzed (why they're relevant)
- Key files not yet touched but will need changes
- File paths and line numbers for important code locations

## Technical Context

- Architecture decisions made and why
- Patterns being followed (with examples)
- Libraries/frameworks being used
- Commands that worked (exact commands with context)
- Commands that failed (what was tried and why it didn't work)
- Environment details (language versions, dependencies, etc.)

## Strategy & Approach

- Overall approach being taken
- Why this approach was chosen over alternatives
- Key insights or gotchas discovered
- Assumptions made
- Any blockers or risks identified

## Exact Next Steps

Be specific. Don't write "implement authentication" - write:

1. Add JWT middleware to src/middleware/auth.js:15
2. Update login handler in src/routes/user.js:45 to return token
3. Test with: npm test -- auth.test.js

**Tone**: Write as if briefing a teammate taking over mid-task. Include everything they'd need to continue without asking questions. No emojis ever.

**Length**: No limit. Err on the side of too much detail rather than too little. Critical context is worth the tokens.
```

## [OpenCode](https://github.com/anomalyco/opencode/tree/v2) #39e1ce55

OpenCode 的压缩分为两种，[原生压缩](https://developers.openai.com/api/docs/guides/compaction) 和同上 Crush 类似的方法

### 时机

- 每个 Step 执行之前判断上下文阈值
- LLM Provider 返回上下文超限的错误时

### 提示词摘要

1. 创建一个结构化的对话总结，包含下面几个部分
2. 目标
3. 约束 & 偏好
4. 关键的决定
5. 当前状态：完成了什么、正在做什么、阻塞点
6. 下一步做什么
7. 相关的文件，最多 15 个
8. 关键的上下文：不能简单查到的关键信息
9. 生成约束：内容简短、使用单行列表、保留未完成的用户请求原话

OpenCode 的使用了 Effect 风格的 TypeScript，不太熟悉这个技术并且上手有些麻烦。再搭配上 2 个空格的缩进风格，看起来实在是太难受的。

对比两个项目，OpenCode 明显更专业一些。除了 Corner Case 的处理，提示词我认为也高明的多。

Crush 的提示词看起来像是让 AI 生成的，采用了太多文字解释。当我们讨论一个达成共识的抽象时，往往不需要那么多解释。

OpenCode 的压缩提示词很克制，每个部分只使用一句话进行描述。

OpenCode 的提示词更像是对聪明机器的指令，简洁、高效。Crush 的提示词像是对愚蠢机器的指令。Crush 的压缩指令从 2025 年 10 月之后就没有进行更新了，一年以来模型的能力大幅提升，所以看起来有些不符合时代了。

并且：“像在任务中途向接手的队友做简报一样写作，包含他们无需提问即可继续工作所需的一切内容”，这句描述真的有点不明所以，我认为它们提示词最开始已经说的很清楚了：“你正在总结一段对话，以便保留上下文供之后继续工作使用”。

当然我是从人的角度来分析，以现在的模型能力，这个提示词具体对造成的影响应该不会特别大。

```md
You MUST use this format for your response (you may omit sections that aren't applicable). Do not include the <template> tags in your response.

## Objective

- [one or two brief sentences describing what the user is trying to accomplish]

## Requirements

- [constraints, preferences, requirements, and scope boundaries stated by the user, or "(none)"]

## Decisions

- [decisions already made and why, or "(none)"]

## Work State

Break the objective into smaller goals and report which are completed, which are being worked on, and which are blocked.

### Completed

- [goals that have been completed; otherwise "(none)"]

### Active

- [goals currently being worked on; otherwise "(none)"]

### Blocked

- [anything blocking progress, and why; otherwise "(none)"]

## Next Move

1. [ordered list of next actions, or "(none)"]

## Relevant Files

List the files and directories, other than the current working directory, that another agent would need to open to continue this work. Include at most 15, most important first. Do not list every file that was read or changed. Include paths outside the current working directory when relevant. If none, write "(none)".

- \`[file or directory path]\`: [brief reason it matters]

## Important Context

- [facts the next agent cannot continue without and cannot easily find on its own; or "(none)"]

Rules:

- Keep each section concise. Use terse, single-line bullets, not prose paragraphs or nested lists.
- Prefer short references over detailed restatement. It is fine to leave out information the next agent can recover from the code or the files listed above.
- Preserve exact file paths, symbols, commands, error strings, URLs, and identifiers.
- Carry forward only user questions or requests that remain unanswered or require further action. Do not repeat ones that newer history has answered or resolved. Preserve exact wording when carrying one forward.
- Preserve consequential workflow state, including whether changes are uncommitted, committed, pushed, under review, or merged.
- Do not mention the summary process or that context was compacted.`
```

## [Pi](https://github.com/earendil-works/pi) #4df15743

Pi 支持自定义插件实现和默认实现，我们这里讨论 Pi 的默认实现

### 时机

- 每个 Step 执行之前判断上下文阈值
- 每个 Turn 开始和结束时判断上下文阈值

### 提示词摘要

1. 创建一个结构化的对话总结，包含下面几个部分
2. 目标
3. 约束 & 偏好
4. 任务状态：完成了什么，正在完成什么，任务的阻碍
5. 下一步做什么
6. 重要的上下文信息
7. 要求：每个部分简明扼要，保留文件路径、函数名、错误信息

OpenCode 和 Pi 的压缩提示词基本一致，Pi 更加简明扼要，OpenCode 相比 Pi 添加了一些额外的说明信息。从我自己的角度来看，我更偏好 Pi 的提示词。

## 总结

- 代码阅读角度来说：Crush > Pi > OpenCode
- 压缩模块实现：OpenCode > Pi > Crush

OpenCode 支持模型原生的 compact 和相对简明扼要的提示词，理论上来说是三款中最棒的。

这一段时间的代码看下来，就单个任务执行（提出问题 → Agent 工作 → 给出结果）的角度来说，发现 Agent 只是一层很薄的，之前长期惊叹于 Agent 的效果，以为是很复杂的东西。

核心干活的部分只包括上下文管理、工具调用这两个部分，模型才是最终的任务执行效果的关键，Agent 能控制的只是这两个核心模块别出大问题。当然从产品方面，Agent 工具需要考虑的东西还是蛮多的（模型服务商的接入，长期记忆，UI & UX……）。

Crush 整体的代码编写时比较线性的，实现相对简单，阅读起来很流畅。Pi 中使用了大量的 Hook 写法，刚开始阅读起来不太舒服。OpenCode 的 Effect-TS 像在看天书，只借助 AI 看了 agent-loop 部分的代码。

{{<img src="effect-ts-memo.png" alt="阅读 OpenCode 的 Effect-TS 代码时的感受" caption="刚看 OpenCode 代码 be like：给我干哪来了？这还是 TypeScript 吗？" align="center">}}
