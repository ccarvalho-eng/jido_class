# Lesson 02: The Founder Goes Live

In lesson 1, the founder became understandable.

In lesson 2, the founder becomes live.

The studio can already organize ideas through pure `cmd/2` calls, but everything is still local and manual. Nothing reacts to incoming events. Nothing lives inside a runtime. Nothing can be addressed by ID.

This chapter introduces the next Jido step: running the same founder as an `AgentServer` that processes studio signals.

Interactive companion: [`../livebooks/02_founder_runtime.livemd`](../livebooks/02_founder_runtime.livemd)

## What You'll Learn

By the end of this lesson, you should understand:

- how to define a Jido instance module with `use Jido`
- how to run an agent inside `AgentServer`
- how `signal_routes/1` maps signal types to actions
- how to send synchronous signals with `AgentServer.call/2`
- how to send asynchronous signals with `AgentServer.cast/2`
- how to look up running agents through the lesson's Jido instance

## The Story

The founder is no longer alone with a notebook.

Ideas are now arriving as studio events:

- a game idea gets submitted
- the founder greenlights it
- the founder plans the first milestone

That is still the same business flow as lesson 1. The difference is architectural: instead of calling `cmd/2` directly from local code, we now send signals into a running founder process.

This is the moment where the studio stops behaving like a single in-memory planning script and starts behaving like a small event-driven system.

## The Jido Concept

Lesson 1 taught the pure core:

```elixir
{agent, directives} = MyAgent.cmd(agent, action)
```

Lesson 2 wraps that core in runtime infrastructure:

```elixir
{:ok, pid} = FounderRuntime.StudioJido.start_agent(FounderRuntime.FounderAgent, id: "founder-1")
{:ok, agent} = Jido.AgentServer.call(pid, signal)
```

The important idea is that we are not replacing the agent model from lesson 1. We are placing it behind a runtime boundary.

The founder still uses actions and state updates. The runtime is simply what receives a signal, routes it, calls `cmd/2`, and stores the new state.

## What We're Building

We will create:

- `FounderRuntime.StudioJido`
- `FounderRuntime.Application`
- `FounderRuntime.FounderAgent`
- runtime-oriented versions of:
  - `AddIdea`
  - `GreenlightIdea`
  - `PlanMilestone`

The founder still owns:

- the studio name
- the active game idea
- the idea backlog
- the next milestone

But now the founder responds to these signal types:

- `studio.idea_submitted`
- `studio.idea_greenlit`
- `studio.milestone_planned`

## The Code

The lesson's runtime modules live in:

- [`lib/founder_runtime/studio_jido.ex`](./lib/founder_runtime/studio_jido.ex)
- [`lib/founder_runtime/application.ex`](./lib/founder_runtime/application.ex)
- [`lib/founder_runtime/founder_agent.ex`](./lib/founder_runtime/founder_agent.ex)

Core pieces:

```elixir
defmodule FounderRuntime.StudioJido do
  use Jido, otp_app: :founder_runtime
end
```

```elixir
defmodule FounderRuntime.Application do
  use Application

  def start(_type, _args) do
    children = [
      FounderRuntime.StudioJido
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: FounderRuntime.Supervisor)
  end
end
```

```elixir
defmodule FounderRuntime.FounderAgent do
  use Jido.Agent,
    name: "runtime_founder",
    description: "The founder as a live Jido agent that reacts to studio events",
    default_plugins: false,
    schema: [
      studio_name: [type: :string, default: "Starboard Studio"],
      active_idea: [type: :string, default: nil],
      idea_backlog: [type: {:list, :map}, default: []],
      next_milestone: [type: :string, default: nil]
    ]

  def signal_routes(_ctx) do
    [
      {"studio.idea_submitted", FounderRuntime.Actions.AddIdea},
      {"studio.idea_greenlit", FounderRuntime.Actions.GreenlightIdea},
      {"studio.milestone_planned", FounderRuntime.Actions.PlanMilestone}
    ]
  end
end
```

The actions themselves still return state updates exactly the way lesson 1 taught. What changes is how those actions are selected and executed.

## Trying It Out

Run the lesson:

```bash
cd 02_founder_runtime
mix deps.get
mix test
```

If your shell is not already using asdf shims first:

```bash
PATH="$HOME/.asdf/shims:$HOME/.asdf/bin:$PATH" mix test
```

You can also run the founder live in `iex`:

```bash
PATH="$HOME/.asdf/shims:$HOME/.asdf/bin:$PATH" iex -S mix
```

Then:

```elixir
alias FounderRuntime.{FounderAgent, StudioJido}
alias Jido.AgentServer
alias Jido.Signal

{:ok, pid} = StudioJido.start_agent(FounderAgent, id: "founder-1")

{:ok, _agent} =
  AgentServer.call(
    pid,
    Signal.new!(
      "studio.idea_submitted",
      %{
        name: "Orbit Cafe",
        genre: "cozy sim",
        hook: "Run a coffee shop on a drifting station"
      },
      source: "/founder/notebook"
    )
  )

{:ok, _agent} =
  AgentServer.call(pid, Signal.new!("studio.idea_greenlit", %{name: "Orbit Cafe"}, source: "/lead"))

{:ok, final_agent} =
  AgentServer.call(
    pid,
    Signal.new!("studio.milestone_planned", %{milestone: "build a playable prototype"}, source: "/lead")
  )

final_agent.state
```

You should see the founder state updated from signals, not from direct local `cmd/2` calls.

## What the Tests Prove

The runtime test suite in [`test/founder_runtime_test.exs`](./test/founder_runtime_test.exs) proves three distinct behaviors:

- the founder can process studio signals synchronously through `AgentServer.call/2`
- the founder can process the same workflow asynchronously through `AgentServer.cast/2`
- the lesson's Jido instance can look up and list the running founder by ID

That third point matters because it turns the founder into a managed runtime entity instead of a value you only hold locally.

## Why This Matters

This lesson is the bridge between pure logic and live systems.

The founder still behaves predictably because the underlying agent model is unchanged. But now the founder can:

- receive messages from outside the current function call
- live under a supervisor
- be addressed by identity
- accumulate state across runtime interactions

This is the first moment where the studio starts to feel like software that could keep running on its own.

## Why We Still Have Only One Agent

We are still deliberately keeping the cast small.

This lesson is about one new concept cluster:

- runtime
- signals
- routing

If we introduced backoffice, recruiting, and engineering at the same time, the reader would have to learn message-driven execution and multi-agent design simultaneously. That would dilute both lessons.

For now, one founder is enough. The founder simply has a live inbox.

## Jido Takeaway

Jido's runtime model does not replace pure agent logic. It operationalizes it.

The agent still defines state and behavior. The runtime makes that behavior addressable, persistent across calls, and event-driven.

## What the Studio Can Do Now

The studio can now:

- run a founder as a managed agent process
- submit ideas as signals
- greenlight a project through the runtime
- plan milestones through a live founder instance
- look up the founder by ID

That is a real step from a local model to a running system.

## What Still Hurts

The founder is now live, but the founder is still doing everything alone.

Operations are starting to pile up:

- budget questions
- payroll readiness
- hiring approvals

The founder needs new capability, but not necessarily a whole new department process yet.

That is what lesson 3 is for.

## Next Lesson

In [`03_backoffice_plugin`](../03_backoffice_plugin/README.md), we will keep the founder live and introduce operational capability through a plugin.

That is where the studio learns its first reusable extension point.
