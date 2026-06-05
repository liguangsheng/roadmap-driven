---
name: agent-roadmap-execution
description: Use when a user wants an AI coding agent to plan, organize, or execute multi-session roadmap work using milestone directories, executable sprint files, validation evidence, and per-sprint commits; applies to roadmap structure, milestone/sprint mapping, draft vs planned status, implementation sequencing, pause/resume handoffs, and keeping project plans, docs, and execution evidence aligned.
---

# Agent Roadmap Execution

Use this skill to structure and drive a project through a tree-shaped roadmap where milestones define completion gates and sprints define executable work.

This workflow borrows milestone and sprint terminology, but does not implement Scrum. Here, a sprint means an executable, verifiable, resumable work package for an AI coding agent.

Use it for multi-step, multi-session, or roadmap-driven work. Do not create roadmap structure for trivial one-shot fixes unless the user asks.

## Core Model

```txt
milestone = phase goal and acceptance gate
sprint    = executable task checklist
```

Milestones own sprints. A sprint must live under the milestone it serves.

Recommended layout:

```txt
docs/roadmap/
  README.md
  M00-short-name/
    README.md
    S000-first-sprint.md
  M01-short-name/
    README.md
    S001-next-sprint.md
```

Keep any old flat `milestones.md`, `PLAN.md`, or `sprints/` file only as a compatibility entry if needed. The tree should be the authority once created.

## Milestone Creation Guard

- Do not create new milestones, extend milestone numbering, or add future milestone README files unless the user explicitly asks to create, expand, replan, or split milestones/roadmap.
- Execution requests such as "continue", "resume", "推进下一个 sprint", "按 roadmap 执行", "fix this", or "finish the current milestone" are not permission to add milestones.
- During execution, if new future work is discovered, record it in the current sprint Evidence/Notes, the current milestone Open Questions, or an existing backlog if one already exists. If no appropriate place exists, report it to the user and ask before changing roadmap scope.
- Updating existing milestone/sprint status, evidence, links, Resume Point, or sprint tables for the work already selected is allowed; creating a new milestone is a separate planning action requiring explicit user intent.

## Status Rules

Use these milestone statuses consistently:

- `draft`: milestone has a README only; direction exists but executable sprint breakdown is missing.
- `planned`: milestone has at least one executable sprint with tasks, tests, commands, and Done criteria.
- `in-progress`: at least one sprint is actively being executed.
- `done`: required sprints and milestone acceptance criteria are complete and verified.

Do not mark a README-only milestone as `planned`.

Use these sprint statuses consistently:

- `planned`: sprint is executable but has not started.
- `in-progress`: sprint is currently being worked.
- `blocked`: sprint cannot continue without a decision, missing dependency, or failing prerequisite.
- `done`: sprint Done criteria and validation commands have passed.

Milestone status derives from sprint state:

- all sprints `planned` -> milestone `planned`;
- any sprint `in-progress` or `blocked` -> milestone `in-progress`;
- all required sprints `done` and acceptance criteria pass -> milestone `done`.

## Roadmap README

Create or update `docs/roadmap/README.md` with:

- status definitions;
- milestone table linking to each `Mxx-*/README.md`;
- tracking rules;
- sprint status rules for pause/resume;
- rule that future milestones remain `draft` until split into sprint files;
- completion rule: sprint Done criteria plus milestone acceptance criteria must both pass.

## Milestone README Template

Each milestone directory must have `README.md`:

```markdown
# Mxx: Title

Status: draft|planned|in-progress|done

## Goal

...

## Scope

- ...

## Sprint Status

| Sprint | Status | Notes |
| --- | --- | --- |
| [Sxxx-name.md](Sxxx-name.md) | planned | ... |

## Resume Point

Start at the first sprint whose status is not `done`. If one is `in-progress`, resume there before starting later sprints.

## Acceptance Criteria

- ...

## Open Questions

- ...

## Decisions

- ...

## Out of Scope

- ...
```

If there are no sprint files yet, set status to `draft` and write “Split when the previous milestone is close to done.”

## Sprint Template

Each sprint file must be directly executable:

```markdown
# Sxxx: Title

Milestone: Mxx Title.

## Goal

...

## Preconditions

- ...

## Files

- ...

## Tasks

- [ ] ...

## Tests

- ...

## Validation Commands

```txt
...
```

## Evidence

- Validation:
- Commit:
- Notes:

## Done Criteria

- ...

## Out of Scope

- ...
```

## Operating Workflow

When asked to plan or reorganize:

1. Inspect existing docs and tree first.
2. Identify the authoritative planning surface.
3. Confirm the request explicitly permits roadmap expansion before creating any new milestone.
4. If flat milestones/sprints exist, migrate to `docs/roadmap/Mxx-*/` only when the user asked for roadmap setup or reorganization.
5. Keep long-range milestones as `draft` unless they have executable sprints.
6. Split only the next actionable milestone into sprint files.
7. Update all links in README, implementation plans, and compatibility docs.
8. Verify no stale paths remain with `rg`.

When asked to execute:

1. Start from the current milestone README.
2. If the project is in a Git repository, run `git status -sb` before selecting or editing a sprint. Distinguish pre-existing user changes from agent-owned changes, and do not overwrite unrelated user work.
3. Find the first sprint whose status is not `done`; prefer an existing `in-progress` sprint over later planned sprints.
4. Mark the selected sprint `in-progress` before editing code.
5. Do not add new milestones while executing; unexpected future work should be noted or reported, not turned into roadmap scope without explicit user approval.
6. Execute sprint tasks in order.
7. Update checklist status as work completes.
8. Run validation commands.
9. Record validation results in the sprint Evidence section.
10. Mark sprint `done` only when Done criteria and validation pass.
11. Update the owning milestone sprint status table.
12. Mark milestone `done` only when every required sprint is done and acceptance criteria pass.
13. If the project is in a Git repository, commit immediately after each sprint is marked `done`, before starting the next sprint. Keep generated build outputs out of the commit, use a commit message that names the completed sprint or milestone slice, and record the commit hash in the sprint Evidence section or milestone sprint table.

When pausing or handing off:

1. Leave the current sprint as `in-progress` unless it is truly blocked or done.
2. Record the next concrete task in the milestone README `Resume Point` or sprint notes.
3. Keep validation evidence in the sprint file or a referenced evidence artifact.
4. If blocked, record the exact blocker, failed command or output summary, last safe state, and smallest user decision or external dependency needed.
5. Do not advance later sprint statuses speculatively.

## Quality Gates

- Milestone acceptance criteria answer “what proves this phase is complete?”
- Sprint Done criteria answer “what proves this task slice is complete?”
- A milestone can be directionally useful as `draft`, but it is not executable until `planned`.
- A milestone README must track sprint status so work can pause and resume without reconstructing context from chat.
- Avoid detailed sprint planning for far-future milestones; it drifts before execution.
- Prefer repo-local docs and checklists over chat-only plans.
- For Git-backed projects, sprint completion is not fully durable until the verified sprint changes are committed separately from later sprint work.
