# jido_class

`jido_class` teaches Jido by following the slow brightening of a tiny autonomous game studio.

The series begins with one founder agent and gradually adds runtime behavior, plugins, specialized child agents, recurring operations, observability, and AI assistance. Each lesson stands on its own, but together they follow the same company as it learns how to think, delegate, and keep its footing.

Each new role opens a new Jido idea. The point is not to decorate the org chart with titles. The point is to let the studio grow in believable steps while every chapter introduces a fresh coordination pattern.

## Interactive Companions

Livebook companions for the full series live in [`livebooks/`](./livebooks/README.md).

- [`livebooks/01_founder_bootstrap.livemd`](./livebooks/01_founder_bootstrap.livemd)
- [`livebooks/02_founder_runtime.livemd`](./livebooks/02_founder_runtime.livemd)
- [`livebooks/03_backoffice_plugin.livemd`](./livebooks/03_backoffice_plugin.livemd)
- [`livebooks/04_spawn_backoffice_and_recruiter.livemd`](./livebooks/04_spawn_backoffice_and_recruiter.livemd)
- [`livebooks/05_hire_a_cto.livemd`](./livebooks/05_hire_a_cto.livemd)
- [`livebooks/06_engineering_org.livemd`](./livebooks/06_engineering_org.livemd)
- [`livebooks/07_product_design_qa_rhythm.livemd`](./livebooks/07_product_design_qa_rhythm.livemd)
- [`livebooks/08_ai_studio_mode.livemd`](./livebooks/08_ai_studio_mode.livemd)

## The Journey

Each lesson is its own standalone Mix project, but the company and the framework ideas advance together:

1. [`01_founder_bootstrap`](./01_founder_bootstrap/README.md)
   One founder gets organized around a game idea, and the reader learns pure agents, actions, and `cmd/2`.
2. [`02_founder_runtime`](./02_founder_runtime/README.md)
   The founder becomes a live runtime participant, and the reader learns signals, routing, and `AgentServer`.
3. [`03_backoffice_plugin`](./03_backoffice_plugin/README.md)
   The founder gains operational capability before hiring a team, and the reader learns plugins and capability composition.
4. [`04_spawn_backoffice_and_recruiter`](./04_spawn_backoffice_and_recruiter/README.md)
   The CEO hires support functions first, and the reader learns spawned hierarchies and parent-child reporting.
5. [`05_hire_a_cto`](./05_hire_a_cto/README.md)
   The CEO hires a CTO to own technical direction, and the reader learns domain ownership boundaries and executive summaries.
6. [`06_engineering_org`](./06_engineering_org/README.md)
   The CTO builds an execution layer with managers and engineers, and the reader learns fan-out, aggregation, and team-level coordination.
7. [`07_product_design_qa_rhythm`](./07_product_design_qa_rhythm/README.md)
   The CEO stops being the default product owner as product, design, and QA add rhythm, and the reader learns recurring workflows, visibility, and feedback loops under pressure.
8. [`08_ai_studio_mode`](./08_ai_studio_mode/README.md)
   AI arrives last, after the human-style boundaries are already clear, and the reader learns how to layer runtime instruction execution onto already-coherent roles.

## Final Company Shape

By the end of the tutorial, the studio looks roughly like this:

```text
CEOAgent
|- BackofficeAgent
|- RecruiterAgent
|- CTOAgent
|  `- EngineeringManagerAgent
|     |- EngineerAgent (gameplay)
|     `- EngineerAgent (ui)
`- ProductManagerAgent
   |- DesignerAgent
   `- QAAgent
```

That chart is intentionally small. It is enough structure to feel like a real startup without turning the tutorial into a corporate diagram.

The repo root only holds the series guide. Each chapter owns its own code, dependencies, and tests.

## Beyond the Series

The eight main chapters already cover the core Jido arc most readers need:

- pure `cmd/2`
- runtime signals and directives
- plugins
- spawned hierarchies
- domain boundaries
- fan-out and aggregation
- recurring loops
- runtime AI boundaries

Jido has a few deeper branches that could become bonus chapters or appendices later:

- **Sensors**: a strong fit for a post-launch chapter where the studio starts listening to ambient signals such as playtest telemetry, crash alerts, or market events. Jido’s sensor runtime is designed for exactly that kind of external monitoring surface.
- **Cron-backed recurring jobs**: lesson 7 teaches short scheduled loops with `Directive.schedule/2`, but Jido also supports recurring cron directives when the studio needs longer-lived operational rhythms.
- **Persistence and hibernation**: once agents represent durable operational state, Jido’s persistence and `InstanceManager` lifecycle become relevant for waking the same company back up instead of rebuilding it from scratch.
- **FSM strategy**: if the studio ever needs a more explicit release pipeline or approval flow, Jido’s FSM strategy offers a more formal execution-state model around `cmd/2`.

Those are worth learning. They simply sit one layer past the story this series is trying to tell.

## Tooling

The repo is pinned with `.tool-versions` so the lessons run against an asdf-managed Elixir and Erlang toolchain that matches Jido's supported baseline.

If your shell is not already resolving asdf shims first, prefix commands like this:

```bash
PATH="$HOME/.asdf/shims:$HOME/.asdf/bin:$PATH" mix test
```

For the Livebook companions, use the repo-root helper scripts:

```bash
./scripts/install_livebook.sh
./scripts/livebook.sh server livebooks
```

## Start Here

Begin with [`01_founder_bootstrap`](./01_founder_bootstrap/README.md).

That chapter introduces the central Jido contract:

```elixir
{agent, directives} = MyAgent.cmd(agent, action)
```

Before the studio gets a runtime or a team, it first needs a founder whose behavior is explicit and testable.
