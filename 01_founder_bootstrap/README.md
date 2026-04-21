# Lesson 01: The Founder Gets Organized

The studio does not exist yet. There is no team, no runtime, and no automation.

There is only a founder with too many ideas and not enough structure.

In this first lesson, we build the smallest useful piece of the company: a `FounderAgent` that can hold the studio's early state, evaluate game ideas, and update priorities through pure `cmd/2` calls.

This chapter is intentionally small. The goal is not to build a full company. The goal is to understand the core Jido mental model before we add signals, runtime processes, or multiple agents.

## What You'll Learn

By the end of this lesson, you should understand:

- how to define a Jido agent with `use Jido.Agent`
- how to define actions with `use Jido.Action`
- how agent state is modeled with a schema
- how `cmd/2` works as a pure state transformation
- why Jido separates decision logic from runtime side effects

## The Story

Our game studio begins with one person: the founder.

The founder is trying to answer a simple question:

> Which game idea should the studio build first?

Right now, the founder needs to do three things well:

- keep track of candidate game ideas
- choose one idea to pursue
- set an initial milestone for the studio

There is no need for a running process yet. No signals. No child agents. No scheduling.

A pure agent is enough.

## The Jido Concept

This lesson focuses on the most important Jido contract:

```elixir
{agent, directives} = MyAgent.cmd(agent, action)
```

That line is the heart of the framework.

An agent receives an action, returns updated state, and optionally returns directives for the runtime to execute later.

In this lesson, our founder mostly changes state, so the interesting part is the updated agent. The directives are still present because they are part of the contract, but they stay empty for the happy path.

## What We're Building

We will create:

- a `FounderAgent`
- an `AddIdea` action
- a `GreenlightIdea` action
- a `PlanMilestone` action

The founder will manage:

- the studio name
- the active game idea
- a backlog of candidate ideas
- the next milestone

## The Code

This lesson's implementation lives in [`lib/founder_bootstrap.ex`](./lib/founder_bootstrap.ex).

```elixir
defmodule JidoClass.FounderAgent do
  use Jido.Agent,
    name: "founder",
    description: "Keeps the studio's early ideas and first milestone organized",
    default_plugins: false,
    schema: [
      studio_name: [type: :string, default: "Starboard Studio"],
      active_idea: [type: :string, default: nil],
      idea_backlog: [type: {:list, :map}, default: []],
      next_milestone: [type: :string, default: nil]
    ]
end

defmodule JidoClass.Actions.AddIdea do
  use Jido.Action,
    name: "add_idea",
    description: "Adds a game idea to the studio backlog",
    schema: [
      name: [type: :string, required: true],
      genre: [type: :string, required: true],
      hook: [type: :string, required: true]
    ]

  def run(params, context) do
    backlog = Map.get(context.state, :idea_backlog, [])

    idea = %{
      name: params.name,
      genre: params.genre,
      hook: params.hook
    }

    {:ok, %{idea_backlog: backlog ++ [idea]}}
  end
end

defmodule JidoClass.Actions.GreenlightIdea do
  use Jido.Action,
    name: "greenlight_idea",
    description: "Selects the studio's active game idea",
    schema: [
      name: [type: :string, required: true]
    ]

  def run(%{name: name}, context) do
    backlog = Map.get(context.state, :idea_backlog, [])

    case Enum.find(backlog, &(&1.name == name)) do
      nil ->
        {:error, Jido.Error.validation_error("Idea is not in the backlog", idea_name: name)}

      idea ->
        {:ok, %{active_idea: idea.name}}
    end
  end
end

defmodule JidoClass.Actions.PlanMilestone do
  use Jido.Action,
    name: "plan_milestone",
    description: "Sets the studio's next delivery milestone",
    schema: [
      milestone: [type: :string, required: true]
    ]

  def run(%{milestone: milestone}, _context) do
    {:ok, %{next_milestone: milestone}}
  end
end
```

## Trying It Out

The repo root already includes `.tool-versions`, so the simplest path is:

```bash
cd 01_founder_bootstrap
mix deps.get
mix test
```

If your shell is not already resolving asdf shims first, use:

```bash
PATH="$HOME/.asdf/shims:$HOME/.asdf/bin:$PATH" mix test
```

You can also inspect the flow in `iex`:

```bash
PATH="$HOME/.asdf/shims:$HOME/.asdf/bin:$PATH" iex -S mix
```

Then try:

```elixir
alias JidoClass.FounderAgent
alias JidoClass.Actions.{AddIdea, GreenlightIdea, PlanMilestone}

founder = FounderAgent.new()

{founder, []} =
  FounderAgent.cmd(
    founder,
    {AddIdea,
     %{
       name: "Dungeon Postal",
       genre: "management sim",
       hook: "Deliver mail in a cursed dungeon"
     }}
  )

{founder, []} =
  FounderAgent.cmd(
    founder,
    {AddIdea,
     %{
       name: "Orbit Cafe",
       genre: "cozy sim",
       hook: "Run a coffee shop on a drifting station"
     }}
  )

{founder, []} = FounderAgent.cmd(founder, {GreenlightIdea, %{name: "Orbit Cafe"}})
{founder, []} = FounderAgent.cmd(founder, {PlanMilestone, %{milestone: "build a playable prototype"}})

founder.state
```

You should see a founder who now has:

- a backlog of ideas
- an active game choice
- a clear next milestone

## What the Test Proves

The lesson test in [`test/founder_bootstrap_test.exs`](./test/founder_bootstrap_test.exs) proves two things:

- the founder can move from blank state to a chosen project and first milestone through pure `cmd/2` calls
- trying to greenlight an idea that does not exist leaves state unchanged and emits a Jido error directive

That second case matters because it shows that even in a pure setup, failure is still explicit and inspectable.

## Why This Matters

This lesson establishes a pattern the rest of the series will keep using:

- the agent holds structured state
- actions describe valid changes
- `cmd/2` applies those changes predictably
- the result is data, not hidden mutation

That gives you something extremely useful early on: confidence.

You can test this logic without processes, supervision trees, or async timing. Before the studio becomes autonomous, it first becomes understandable.

## Why We Are Not Using Runtime Yet

Jido also supports long-running agents, signal routing, directives, orchestration, and supervision.

We are deliberately not using those yet.

At this stage in the story, the founder does not need a live runtime. The founder just needs a reliable decision model.

Introducing runtime too early would make the first lesson noisier than it needs to be.

## Jido Takeaway

Jido starts with a simple but powerful idea:

> agent logic should be expressed as explicit state transitions, not hidden process behavior.

That is why `cmd/2` comes first.

Before we build a company of specialized agents, we first need one agent whose behavior is clear.

## What the Studio Can Do Now

The studio can now:

- store multiple game ideas
- choose a project
- define an initial milestone

That may not look dramatic yet, but it is the first real structure in the company.

## What Still Hurts

The founder still has a major limitation:

- everything is happening locally
- nothing reacts to external events
- there is no running agent process
- there is no message-driven workflow

The next lesson solves that.

## Next Lesson

In [`02_founder_runtime`](../02_founder_runtime/README.md), we will keep the same founder, but move from pure local state transitions into Jido's runtime model.

That is where signals and `AgentServer` enter the story.
