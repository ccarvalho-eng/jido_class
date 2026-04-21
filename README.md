# jido_class

`jido_class` teaches Jido by following the growth of a tiny autonomous game studio.

The series starts with one founder agent and gradually adds runtime behavior, plugins, specialized child agents, recurring operations, observability, and AI assistance. Each lesson is designed to be understandable on its own while still continuing the same company storyline.

## How This Repo Is Structured

- `01_founder_bootstrap` is a complete, runnable Mix project
- `02` through `08` are scaffolded chapter directories that describe the next steps in the series
- the repo root is only for series documentation; each runnable lesson owns its own Elixir project files

## Current Lesson Status

| Lesson | Focus | Status |
| --- | --- | --- |
| `01_founder_bootstrap` | Pure agents, actions, and `cmd/2` | Implemented |
| `02_founder_runtime` | Signals, routing, and `AgentServer` | Scaffolded |
| `03_backoffice_plugin` | Plugins and operational capabilities | Scaffolded |
| `04_spawn_backoffice_and_recruiter` | Spawning specialized child agents | Scaffolded |
| `05_hire_engineer_and_build` | Multi-agent milestone delivery | Scaffolded |
| `06_add_qa_and_recurring_ops` | Scheduling and recurring workflows | Scaffolded |
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
