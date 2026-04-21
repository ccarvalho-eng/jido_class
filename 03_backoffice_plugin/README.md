# Lesson 03: The Founder Needs Operations

The founder is now live, but the founder is still doing everything alone.

The studio has a runtime, an ID, and a signal-driven workflow. What it does not yet have is a clean way to add operational capability without turning the founder into a giant all-purpose module.

This lesson introduces plugins as the answer to that problem.

## What You'll Learn

By the end of this lesson, you should understand:

- how to define a Jido plugin with `use Jido.Plugin`
- how plugin-owned state is mounted under a namespaced state key
- how plugin routes add new runtime behavior without bloating the base agent
- how to keep intangible business concepts like budget and payroll as structured state
- how a live founder can keep its core behavior while gaining reusable operational capability

## The Story

The founder can already react to live studio events like submitted ideas and planned milestones.

That quickly creates a new problem: operations.

The founder now needs to deal with:

- budget allocation
- hiring approvals
- payroll readiness

Those are real studio concerns, but they are not a reason to turn operations into a separate autonomous department process yet. The company is still small.

Instead, this chapter adds a backoffice capability to the founder as a plugin.

The founder stays the same role. The system simply gains a new operational surface.

## The Jido Concept

Plugins are Jido’s way of packaging:

- state
- actions
- routes
- configuration

into a reusable capability module.

Instead of adding financial state fields directly to the founder schema, we mount a `BackofficeCapability` plugin that owns its own slice of state:

```elixir
agent.state.backoffice
```

That keeps the agent modular and teaches an important modeling rule for the rest of the series:

> agents represent roles, while plugins represent reusable capabilities.

## What We're Building

We will create:

- `BackofficePlugin.StudioJido`
- `BackofficePlugin.FounderAgent`
- `BackofficePlugin.BackofficeCapability`
- backoffice actions for:
  - budget allocation
  - hiring approval
  - payroll readiness

The founder still owns:

- the studio name
- the backlog of game ideas
- the active idea
- the next milestone

The plugin now owns:

- `monthly_budget`
- `hiring_budget`
- `allocations`
- `approved_roles`
- `payroll_ready`

## The Code

The lesson’s code lives in:

- [`lib/backoffice_plugin/studio_jido.ex`](./lib/backoffice_plugin/studio_jido.ex)
- [`lib/backoffice_plugin/founder_agent.ex`](./lib/backoffice_plugin/founder_agent.ex)
- [`lib/backoffice_plugin/actions.ex`](./lib/backoffice_plugin/actions.ex)

The plugin itself:

```elixir
defmodule BackofficePlugin.BackofficeCapability do
  use Jido.Plugin,
    name: "backoffice",
    state_key: :backoffice,
    actions: [
      BackofficePlugin.Actions.AllocateBudget,
      BackofficePlugin.Actions.ApproveHire,
      BackofficePlugin.Actions.MarkPayrollReady
    ],
    schema:
      Zoi.object(%{
        monthly_budget: Zoi.integer() |> Zoi.default(12_000),
        hiring_budget: Zoi.integer() |> Zoi.default(4_000),
        allocations: Zoi.list(Zoi.map()) |> Zoi.default([]),
        approved_roles: Zoi.list(Zoi.string()) |> Zoi.default([]),
        payroll_ready: Zoi.boolean() |> Zoi.default(false)
      }),
    signal_patterns: ["*"],
    signal_routes: [
      {"budget_allocated", BackofficePlugin.Actions.AllocateBudget},
      {"hiring_approved", BackofficePlugin.Actions.ApproveHire},
      {"payroll_marked_ready", BackofficePlugin.Actions.MarkPayrollReady}
    ]
end
```

Mounted into the founder:

```elixir
defmodule BackofficePlugin.FounderAgent do
  use Jido.Agent,
    name: "backoffice_founder",
    default_plugins: false,
    schema: [
      studio_name: [type: :string, default: "Starboard Studio"],
      active_idea: [type: :string, default: nil],
      idea_backlog: [type: {:list, :map}, default: []],
      next_milestone: [type: :string, default: nil]
    ],
    plugins: [
      {BackofficePlugin.BackofficeCapability, %{monthly_budget: 12_000, hiring_budget: 4_000}}
    ]
end
```

Because the plugin is named `backoffice`, its public signal names become:

- `backoffice.budget_allocated`
- `backoffice.hiring_approved`
- `backoffice.payroll_marked_ready`

That prefixing is an important Jido plugin detail: the plugin owns a capability namespace.

## Trying It Out

Run the lesson:

```bash
cd 03_backoffice_plugin
mix deps.get
mix test
```

If your shell is not already using asdf shims first:

```bash
PATH="$HOME/.asdf/shims:$HOME/.asdf/bin:$PATH" mix test
```

You can also inspect the founder with its plugin in `iex`:

```bash
PATH="$HOME/.asdf/shims:$HOME/.asdf/bin:$PATH" iex -S mix
```

Then:

```elixir
alias BackofficePlugin.{FounderAgent, StudioJido}
alias Jido.AgentServer
alias Jido.Signal

{:ok, pid} = StudioJido.start_agent(FounderAgent, id: "founder-ops")

{:ok, _founder} =
  AgentServer.call(
    pid,
    Signal.new!("backoffice.budget_allocated", %{category: "art", amount: 1_500}, source: "/ops")
  )

{:ok, founder} =
  AgentServer.call(
    pid,
    Signal.new!("backoffice.hiring_approved", %{role: "engineer"}, source: "/ops")
  )

founder.state.backoffice
```

You should see the founder’s `backoffice` state updated independently from the founder’s core planning fields.

## What the Tests Prove

The lesson 3 tests in [`test/backoffice_plugin_test.exs`](./test/backoffice_plugin_test.exs) prove three behaviors:

- plugin state mounts under `agent.state.backoffice`
- plugin-owned runtime signals update plugin-owned state
- the founder still handles core studio behavior while the plugin handles operations

That last point is the whole lesson: new capability is added without rewriting the founder into a different kind of agent.

## Why This Matters

This lesson is the first one where the design starts resisting bloat.

Without plugins, it would be tempting to keep adding:

- `monthly_budget`
- `approved_roles`
- `payroll_ready`

directly into the founder schema forever.

That would work for a while, but the agent would slowly stop being understandable.

With a plugin:

- the founder keeps its core role
- operations get their own state namespace
- runtime routes stay grouped by capability
- the same capability can later be reused elsewhere if the story needs it

## Why Budget Is State, Not an Agent

This chapter also reinforces a modeling rule for the whole series.

`budget` and `payroll` are important, but they are not autonomous actors yet. They are structured business concepts owned by the operational capability.

So in this lesson:

- the founder is still the agent
- backoffice is the plugin
- budget and payroll are state

That keeps the architecture proportional to the story.

## Jido Takeaway

Plugins let you extend an agent without changing what that agent fundamentally is.

That is the difference between:

- a role becoming too broad
- and a role gaining a well-bounded capability

## What the Studio Can Do Now

The studio can now:

- keep the founder live at runtime
- submit and track ideas
- attach an operational capability to the founder
- allocate budget
- approve hires
- mark payroll readiness

The founder is no longer just planning work. The founder now has a usable operational extension.

## What Still Hurts

The founder now has more capability, but the founder is still the only live role in the company.

The next architectural jump is different:

- not more capability inside the founder
- but new specialized child agents

That is where the company actually starts to feel like a team.

## Next Lesson

In [`04_spawn_backoffice_and_recruiter`](../04_spawn_backoffice_and_recruiter/README.md), we will stop extending the founder in-place and start spawning specialized child agents.

That is where the studio begins to grow beyond one runtime role.
