# jido_class

`jido_class` teaches Jido by following the growth of a tiny autonomous game studio.

The series starts with one founder agent and gradually adds runtime behavior, plugins, specialized child agents, recurring operations, observability, and AI assistance. Each lesson is designed to be understandable on its own while still continuing the same company storyline.

Each new role is also a new Jido teaching surface. The course should not repeat the same pattern with different job titles. Instead, every added agent type exists because it lets the story introduce a new runtime or coordination idea cleanly.

## Story Progression

The company should grow in a way that still feels like a real startup:

1. one founder gets organized
2. the founder becomes a live runtime participant
3. the founder gains operational capability before hiring a team
4. the CEO hires support functions first: operations and recruiting
5. the CEO hires a CTO to own technical direction
6. the CTO adds engineering management and engineers for execution
7. the studio adds recurring delivery rhythm, QA pressure, and the visibility needed to trust that rhythm
8. AI is added last, on top of clear human-style role boundaries

The teaching progression should mirror that company growth:

1. `cmd/2` and pure state transitions
2. runtime signals and `AgentServer`
3. plugins and capability composition
4. spawned child hierarchies and parent-child reporting
5. domain ownership boundaries and executive summaries
6. fan-out, aggregation, and team-level execution coordination
7. recurring workflows, testability, and observability under operational pressure
8. AI assistance layered onto already-clear agent responsibilities

## How This Repo Is Structured

- `01_founder_bootstrap` is a complete, runnable Mix project
- `02_founder_runtime`, `03_backoffice_plugin`, `04_spawn_backoffice_and_recruiter`, and `05_hire_engineer_and_build` are also complete, runnable Mix projects
- `06` through `08` are scaffolded chapter directories that describe the next steps in the series
- the repo root is only for series documentation; each runnable lesson owns its own Elixir project files

## Current Lesson Status

| Lesson | Focus | Status |
| --- | --- | --- |
| `01_founder_bootstrap` | Pure agents, actions, and `cmd/2` | Implemented |
| `02_founder_runtime` | Signals, routing, and `AgentServer` | Implemented |
| `03_backoffice_plugin` | Plugins and operational capabilities | Implemented |
| `04_spawn_backoffice_and_recruiter` | Spawning backoffice and recruiting support | Implemented |
| `05_hire_engineer_and_build` | Introducing the CTO and technical handoff | Implemented |
| `06_add_qa_and_recurring_ops` | Adding engineering management and recurring delivery loops | Scaffolded |
| `07_observability_and_testability` | Testing and observability | Scaffolded |
| `08_ai_studio_mode` | AI-assisted workflows with `req_llm` | Scaffolded |

## Tooling

The repo is pinned with `.tool-versions` so the lessons run against an asdf-managed Elixir and Erlang toolchain that matches Jido's supported baseline.

If your shell is not already resolving asdf shims first, prefix commands like this:

```bash
PATH="$HOME/.asdf/shims:$HOME/.asdf/bin:$PATH" mix test
```

## Start Here

Begin with [`01_founder_bootstrap`](./01_founder_bootstrap/README.md).

That chapter introduces the central Jido contract:

```elixir
{agent, directives} = MyAgent.cmd(agent, action)
```

Before the studio gets a runtime or a team, it first needs a founder whose behavior is explicit and testable.
