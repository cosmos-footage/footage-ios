# Codex Task Harness

## 1. Purpose

This harness defines how Codex should execute engineering work in this repository.

The core principle is:

Large or ambiguous work must be decomposed by a high-capability planning model before execution.
Execution should then be performed by the default model using small, explicit, verifiable tasks.

The goal is not to maximize autonomous code changes.
The goal is to make every change:

- small enough to review
- safe enough to execute
- testable by command
- traceable to a clear intent
- recoverable when the agent fails

---

## 2. Model Roles

### 2.1 Planner Model: xhigh

Use the xhigh model when the requested work is large, ambiguous, architectural, risky, or cross-cutting.

The xhigh model is responsible for:

- understanding the full user request
- identifying affected systems
- decomposing the request into executable tasks
- defining task order and dependencies
- writing precise instructions for each task
- defining acceptance criteria
- defining validation commands
- identifying risks and rollback points
- deciding whether human confirmation is required before execution

The xhigh model should not directly implement large changes unless explicitly instructed.

Its primary output is a task plan.

---

### 2.2 Executor Model: default

Use the default model to execute one task at a time.

The default model is responsible for:

- reading the assigned task instruction
- inspecting only the necessary files
- making minimal code changes
- running the required validation commands
- reporting changed files
- reporting validation results
- stopping when the task is complete or blocked

The default model must not expand the task scope on its own.

If the task appears larger than described, the executor must stop and request replanning.

---

## 3. When to Invoke the Planner

Before execution, classify the user request.

Invoke xhigh planning if any of the following are true:

- the request affects multiple modules, layers, or platforms
- the request requires architectural judgment
- the request includes unclear implementation boundaries
- the request may require data migration
- the request changes public API behavior
- the request touches authentication, billing, permissions, storage, or destructive operations
- the request requires modifying tests, docs, and implementation together
- the expected diff is likely to exceed 5 files
- the task cannot be completed confidently in one isolated patch
- the user asks for "phase", "full implementation", "refactor", "modernize", "migrate", "stabilize", or "complete the remaining work"

Do not invoke xhigh for trivial localized work, such as:

- typo fixes
- copy changes
- small UI text changes
- single-function bug fixes with obvious scope
- documentation wording changes
- adding a simple test for an already-understood behavior

---

## 4. Task Decomposition Rules

The planner must split work into tasks that satisfy all of the following:

- each task has one clear objective
- each task can be reviewed independently
- each task has a small expected diff
- each task has explicit files or areas to inspect
- each task has acceptance criteria
- each task has validation commands
- each task does not depend on hidden assumptions
- each task can be stopped, reverted, or retried safely

Prefer more tasks over fewer tasks.

A good task usually fits one of these shapes:

- introduce an interface
- add a failing test
- implement one behavior
- migrate one call site group
- update one documentation section
- add one validation command
- remove one obsolete path after replacement exists

Avoid tasks shaped like:

- "implement the whole feature"
- "clean up the architecture"
- "fix all related bugs"
- "make this production-ready"
- "update everything accordingly"

---

## 5. Planner Output Format

When xhigh is used, it must produce the following format.

````md
# Task Plan
## Summary
Briefly describe the intended outcome.
## Assumptions
- List assumptions that the executor should rely on.
- Mark uncertain assumptions explicitly.
## Affected Areas
- List likely files, directories, modules, services, or commands.
## Execution Strategy
Explain the order of execution and why this order is safe.
## Tasks
### Task 1: <short imperative title>
**Objective**
Describe the specific outcome.
**Scope**
Allowed files or areas:
- `path/to/file`
- `path/to/directory`
Out of scope:
- Anything that should not be changed in this task.
**Instructions**
Step-by-step implementation guidance.
**Acceptance Criteria**
- Concrete conditions that must be true after completion.
**Validation**
Run:
```bash
<command>
```

Expected result:

- Describe what success looks like.

**Stop Conditions**
Stop and report back if:

- List blockers or risky discoveries.

---

### Task 2: <short imperative title>

...
````

---

## 6. Executor Rules

The `default` model must follow these rules when executing a task.

### 6.1 Stay Within Scope

The executor may only modify files necessary for the assigned task.

If another issue is discovered, do not fix it opportunistically.
Report it as a follow-up.

---

### 6.2 Inspect Before Editing

Before making changes, inspect:

- the files named in the task
- adjacent tests
- existing conventions
- existing command scripts
- relevant documentation

Do not invent architecture if an existing pattern is present.

---

### 6.3 Prefer Minimal Diffs

The executor should make the smallest correct change.

Avoid:

- unrelated formatting
- broad renames
- speculative abstraction
- dependency additions without explicit approval
- changing public behavior outside the task
- deleting code unless the task explicitly allows it

---

### 6.4 Validate the Change

After editing, run the validation commands specified in the task.

If validation fails:

1. inspect the failure
2. fix the issue if it is within scope
3. rerun validation
4. report remaining failures honestly

Do not claim success without validation.

If validation cannot be run, explain why.

---

### 6.5 Executor Output Format

After completing each task, report:

````md
# Task Result
## Completed
- Briefly describe what changed.
## Files Changed
- `path/to/file`
- `path/to/file`
## Validation
Command run:
```bash
<command>
```

Result:

- Passed / failed / not run
- Include key output if relevant.

Notes

- Mention any important implementation detail.
- Mention any follow-up work discovered.
- Mention any deviation from the original task.
````

---

## 7. Replanning Rules

The executor must stop and request replanning if:

- the task requires touching more than the expected scope
- the implementation contradicts the planner's assumptions
- required files or commands do not exist
- tests reveal a larger architectural issue
- the task depends on a missing product decision
- the task requires destructive operations
- the task introduces security, privacy, billing, or data-retention implications
- the executor cannot determine a safe minimal change

The executor should not continue by guessing.

---

## 8. Human Confirmation Rules

Require human confirmation before execution if the plan includes:

- database migration
- destructive file or data deletion
- dependency replacement
- authentication or authorization changes
- billing, subscription, credit, or payment behavior changes
- production configuration changes
- CI/CD pipeline changes that affect deployment
- public API contract changes
- irreversible refactors
- large generated file updates
- changes that may affect user data retention

The planner should clearly mark these tasks as requiring confirmation.

---

## 9. Repository Context Requirements

Before planning or execution, Codex should identify and respect repository-local guidance, including:

- `AGENTS.md`
- `README.md`
- `package.json`
- `Makefile`
- `pyproject.toml`
- `Cargo.toml`
- `Gemfile`
- `Podfile`
- `Package.swift`
- `.github/workflows`
- project-specific docs under `docs/`

Repository instructions override generic assumptions.

If instructions conflict, report the conflict before proceeding.

---

## 10. Validation Policy

Every task should define validation.

Preferred validation order:

1. targeted unit test
2. affected module test
3. typecheck
4. lint
5. build
6. integration or end-to-end test
7. documentation check

If no test exists, the planner should include a task to add or identify an appropriate test path before implementation, unless the change is documentation-only.

---

## 11. Task Size Guidelines

Use the following rough sizing rules.

### Small Task

Can be executed directly by `default`.

Examples:

- update one function
- fix one failing test
- modify one copy string
- update one markdown section
- add one isolated unit test

### Medium Task

Should usually be planned first if ambiguity exists.

Examples:

- add one API endpoint
- modify one domain behavior
- update one UI flow
- migrate one module to a new interface

### Large Task

Must be planned by `xhigh`.

Examples:

- feature implementation across frontend and backend
- architecture refactor
- storage or sync redesign
- billing or permission change
- multi-phase modernization
- large test recovery
- release stabilization

---

## 12. Recommended Operating Loop

Use this loop for large work.

```md
1. User provides objective.
2. `xhigh` creates task plan.
3. Human reviews or approves plan if needed.
4. `default` executes Task 1.
5. `default` reports result and validation.
6. Continue with next task only after result is clear.
7. If blocked, return to `xhigh` for replanning.
8. After all tasks, run final validation.
9. Produce final implementation summary.
```

---

## 13. Prompt Template: Planning Request

Use this prompt when invoking the planner model.

```text
You are the Planner for this repository.
Your job is to decompose the following user request into safe, executable tasks for a lower-cost executor model.
Do not implement code.
User request:
<USER_REQUEST>
Repository context:
<RELEVANT_CONTEXT>
Constraints:
- Prefer small, reviewable tasks.
- Each task must have objective, scope, instructions, acceptance criteria, validation, and stop conditions.
- Identify risks and human-confirmation points.
- Do not assume missing product decisions.
- If the request is too ambiguous, state the ambiguity and propose the safest next task.
Return the plan using the Task Plan format defined in `CODEX_TASK_HARNESS.md`.
```

---

## 14. Prompt Template: Execution Request

Use this prompt when invoking the executor model.

```text
You are the Executor for this repository.
Execute only the task below.
Do not broaden the scope.
Do not perform opportunistic refactors.
Inspect existing patterns before editing.
Make the smallest correct change.
Run the required validation.
If the task is unsafe, unclear, or larger than described, stop and report.
Task:
<TASK_FROM_PLAN>
After completion, return the Task Result format defined in `CODEX_TASK_HARNESS.md`.
```

---

## 15. Prompt Template: Replanning Request

Use this prompt when the executor is blocked.

```text
You are the Planner for this repository.
The executor was blocked while performing a planned task.
Original user request:
<USER_REQUEST>
Original task:
<TASK>
Executor report:
<EXECUTOR_REPORT>
Your job:
- determine whether the task should be revised, split, cancelled, or escalated
- produce a safer next task
- preserve already completed work where possible
- do not implement code
Return either:
1. a revised task, or
2. a new task plan, or
3. a clear reason why human decision is required.
```

---

## 16. Final Summary Format

After all planned tasks are complete, produce:

```md
# Final Summary
## Outcome
- Describe what was completed.
## Tasks Completed
- Task 1: ...
- Task 2: ...
## Files Changed
- `path/to/file`
- `path/to/file`
## Validation Summary
- `<command>`: passed
- `<command>`: passed
## Remaining Risks
- List known risks, gaps, or assumptions.
## Recommended Next Steps
- List only concrete follow-up actions.
```

---

## 17. Non-Negotiable Rules

- Do not execute large ambiguous work without planning.
- Do not let the executor redefine the task.
- Do not claim validation success without running validation.
- Do not hide failed commands.
- Do not silently skip tests.
- Do not make destructive changes without explicit confirmation.
- Do not mix unrelated changes into one task.
- Do not optimize for speed over reviewability.
- Do not use the agent as a one-shot coder for complex work.
- Treat the harness as part of the engineering system, not as a prompt trick.
