# jido_class

`jido_class` teaches Jido by following the growth of a tiny autonomous game studio.

The series starts with one founder agent and gradually adds runtime behavior, plugins, specialized child agents, recurring operations, observability, and AI assistance. Each lesson is designed to be understandable on its own while still continuing the same company storyline.

Each new role opens a new Jido idea. The point is not to decorate the org chart with more titles. The point is to let the studio grow in believable steps while each chapter introduces a fresh coordination pattern.

## Story Progression

The company grows the way an ambitious little startup often does:

1. one founder gets organized
2. the founder becomes a live runtime participant
3. the founder gains operational capability before hiring a team
4. the CEO hires support functions first: operations and recruiting
5. the CEO hires a CTO to own technical direction
6. the CTO adds engineering management and engineers for execution
7. the CEO stops being the default product owner as product, design, and QA add recurring delivery rhythm
8. AI arrives last, after the human-style boundaries are already clear

The Jido lessons follow the same arc:

1. `cmd/2` and pure state transitions
2. runtime signals and `AgentServer`
3. plugins and capability composition
4. spawned child hierarchies and parent-child reporting
5. domain ownership boundaries and executive summaries
6. fan-out, aggregation, and team-level execution coordination
7. cross-functional recurring workflows, design-feedback loops, testability, and observability under operational pressure
8. AI assistance layered onto already-clear agent responsibilities

## How This Repo Is Structured

- `01_founder_bootstrap` is a complete, runnable Mix project
- `02_founder_runtime`, `03_backoffice_plugin`, `04_spawn_backoffice_and_recruiter`, and `05_hire_a_cto` are also complete, runnable Mix projects
- `06_engineering_org` is a complete, runnable Mix project
- `07` and `08` are scaffolded chapter directories that describe the next steps in the series
- the repo root is only for series documentation; each runnable lesson owns its own Elixir project files

## Current Lesson Status

| Lesson | Focus | Status |
| --- | --- | --- |
| `01_founder_bootstrap` | Pure agents, actions, and `cmd/2` | Implemented |
| `02_founder_runtime` | Signals, routing, and `AgentServer` | Implemented |
| `03_backoffice_plugin` | Plugins and operational capabilities | Implemented |
| `04_spawn_backoffice_and_recruiter` | Spawning backoffice and recruiting support | Implemented |
| `05_hire_a_cto` | Introducing the CTO and technical ownership boundaries | Implemented |
| `06_engineering_org` | Building the engineering org with fan-out and aggregation | Implemented |
| `07_product_design_qa_rhythm` | Adding product, design, QA, and recurring delivery rhythm | Scaffolded |
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
