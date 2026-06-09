# Agent Roadmap Execution

[中文](README.md) | English

`agent-roadmap-execution` is a Codex skill for planning and executing multi-session AI coding work with milestone directories, executable sprint files, validation evidence, and per-sprint commits.

The skill is designed for repositories where work needs to be paused and resumed without reconstructing context from chat. It keeps roadmap state in repo-local Markdown files and treats every sprint as a verifiable, resumable work package for an AI coding agent.

## Contents

- `SKILL.md`: the skill definition and operating workflow.
- `agents/openai.yaml`: UI metadata for Codex skill lists and default invocation.

## Install

Do not copy the directory manually. Give Codex this prompt and let the agent install the skill directly from the remote repository:

```txt
Please install this Codex skill: https://github.com/liguangsheng/agent-roadmap-execution.git. Check the repository's SKILL.md and agents/openai.yaml, install it into my Codex skills directory, and verify the installation.
```

After installation, invoke it explicitly with:

```txt
$agent-roadmap-execution
```

## What It Enforces

- Milestones represent phase goals and acceptance gates.
- Sprints represent executable, verifiable, resumable task slices.
- `docs/roadmap/` contains only roadmap control-plane documents: the root `README.md`, milestone directories, milestone `README.md` files, and sprint files. Put specs, designs, reports, release notes, evidence attachments, and other auxiliary docs elsewhere under `docs/` and link to them.
- Future milestones stay `draft` until split into executable sprint files.
- Execution resumes from the first non-`done` sprint, preferring an existing `in-progress` sprint.
- New milestones are not created during execution unless the user explicitly asks to expand, replan, split, or create roadmap scope.
- Completed sprints must record validation evidence and pass a deep completion audit of the stated goal. If gaps remain, keep the sprint `in-progress`, close the gaps, then rerun validation and the audit. In Git repositories, commit before moving to the next sprint.

## How to Use

For roadmap-driven work, use two Codex sessions:

- Steering session: discuss project direction with the AI and maintain the roadmap, milestone goals, sprint slices, acceptance gates, validation methods, and Done Criteria.
- Execution session: execute the roadmap without re-litigating direction. Use `/goal` or an equivalent sustained execution mode to let Codex continue from the current Resume Point.

If execution drifts, return to the steering session and adjust the roadmap there. You can mark the affected milestone or sprint as `blocked`, record why it drifted and what condition would unblock it, then explicitly insert a corrective milestone if needed. For example, if M08 should no longer lead directly into M09, pause M09, insert M08.1 after M08, and then let the execution session continue from the new Resume Point.

Notes:

- Keep planning and route changes in the steering session. Do not let the execution session rewrite the roadmap ad hoc, or the two sessions may diverge on project state.
- The execution session should resume the current `in-progress` sprint first; if none exists, it should start the first sprint that is not `done`.
- Before finishing each sprint, record validation evidence and audit the Goal, Tasks, Done Criteria, changed files, and relevant milestone acceptance criteria. If gaps remain, continue filling them instead of moving on just because commands passed. In Git repositories, commit the completed sprint before moving to the next one.
- Use a strong model for roadmap execution, especially when the work involves cross-file edits, long-context recovery, and acceptance judgment.
