# Lesson 05: The CEO Hires a CTO

The company now has support staff, but the technical side of the startup is still wrong.

The CEO can ask for recruiting help. The CEO can ask for hiring reviews. The CEO can keep the company moving.

But the CEO still should not be the person deciding how the game gets built.

This chapter introduces the `CTOAgent` as the first real technical boundary in the company.

## What You'll Learn

By the end of this lesson, you should understand:

- how to introduce a new domain owner without repeating the support-team pattern
- how a parent agent can delegate **outcome ownership** to a child agent
- how the `CTOAgent` can keep detailed technical state while the `CEOAgent` only stores an executive summary
- how child-to-parent signals can carry different levels of detail for different roles
- how to model technical planning as an agent responsibility instead of a generic workflow step

## The Story

The studio is now big enough to hire a CTO.

That changes the company in a way that is deeper than org-chart aesthetics.

Before the CTO exists:

- the CEO still owns technical direction by default
- every engineering question climbs back to the top
- there is no dedicated place for roadmap shape, architecture focus, or hiring intent

After the CTO exists:

- the CEO owns company direction
- the CTO owns technical direction
- the CEO stops micromanaging the inside of the technical plan
- the rest of the engineering org can later hang off a clear technical boundary

That last point is why this chapter exists.

The CTO is not here just to make the company feel more realistic. The CTO is here so the tutorial can teach a new Jido design move:

> one agent becomes the boundary for a whole domain, and the parent only receives the level of detail it actually needs.

## The Jido Concept

Lesson 4 taught runtime hierarchy:

- spawn child agents
- track child relationships
- report child work back upward

Lesson 5 uses the same hierarchy, but teaches a different architectural rule:

> not every child should report its full internal state to the parent.

The CTO owns:

- the technical roadmap
- the first hiring intent for engineering
- the architecture focus for the current milestone

The CEO does **not** store all of that raw state.

Instead, the CEO receives a concise executive update that says:

- what milestone the CTO planned for
- what technical area matters most
- what the first engineering hire should be
- whether the strategy is ready

That is a real boundary.

## What We're Building

We will create:

- `HireEngineerAndBuild.StudioJido`
- `HireEngineerAndBuild.CEOAgent`
- `HireEngineerAndBuild.CTOAgent`

The CEO will:

- receive `studio.technical_leadership_requested`
- spawn the CTO
- record the CTO startup lifecycle event
- store executive summaries from the CTO

The CTO will:

- receive `cto.technical_strategy_requested`
- build the milestone-level technical roadmap
- set the initial hiring intent for engineering
- emit a summary signal back to the CEO

## The Code

The lesson’s code lives in:

- [`lib/hire_engineer_and_build/ceo_agent.ex`](./lib/hire_engineer_and_build/ceo_agent.ex)
- [`lib/hire_engineer_and_build/cto_agent.ex`](./lib/hire_engineer_and_build/cto_agent.ex)
- [`lib/hire_engineer_and_build/actions/request_technical_leadership.ex`](./lib/hire_engineer_and_build/actions/request_technical_leadership.ex)
- [`lib/hire_engineer_and_build/actions/record_child_started.ex`](./lib/hire_engineer_and_build/actions/record_child_started.ex)
- [`lib/hire_engineer_and_build/actions/record_technical_strategy_proposed.ex`](./lib/hire_engineer_and_build/actions/record_technical_strategy_proposed.ex)
- [`lib/hire_engineer_and_build/actions/propose_technical_strategy.ex`](./lib/hire_engineer_and_build/actions/propose_technical_strategy.ex)

The CEO still uses a spawn directive to bring the CTO online:

```elixir
defmodule HireEngineerAndBuild.Actions.RequestTechnicalLeadership do
  alias HireEngineerAndBuild.CTOAgent
  alias Jido.Agent.Directive

  use Jido.Action,
    name: "request_technical_leadership",
    description: "Spawns the CTO as the technical boundary for the studio",
    schema: []

  def run(_params, _context) do
    directive = Directive.spawn_agent(CTOAgent, :cto)
    {:ok, %{leadership_team: ["cto"]}, [directive]}
  end
end
```

But that is not the main idea of the lesson.

The main idea is the CTO’s planning action:

```elixir
defmodule HireEngineerAndBuild.Actions.ProposeTechnicalStrategy do
  alias Jido.Agent.Directive
  alias Jido.Signal

  use Jido.Action,
    name: "propose_technical_strategy",
    description: "Owns the technical roadmap for a milestone and reports a summary upward",
    schema: [
      milestone: [type: :string, required: true],
      product_goal: [type: :string, required: true]
    ]

  def run(%{milestone: milestone, product_goal: product_goal}, context) do
    architecture_focus = "combat pipeline"
    first_hire = "gameplay engineer"

    signal =
      Signal.new!(
        "studio.technical_strategy_proposed",
        %{
          milestone: milestone,
          architecture_focus: architecture_focus,
          first_hire: first_hire,
          status: "technical_strategy_ready"
        },
        source: "/cto"
      )

    directive = Directive.emit_to_parent(context.agent, signal)

    {:ok,
     %{
       technical_roadmap: [
         %{
           milestone: milestone,
           architecture_focus: architecture_focus,
           product_goal: product_goal
         }
       ],
       hiring_intent: [first_hire],
       architecture_decisions: [architecture_focus]
     }, List.wrap(directive)}
  end
end
```

That action is the center of the chapter.

The CTO keeps the detailed technical state. The CEO only gets the summary signal.

## Why This Is Different From Lesson 4

Lesson 4 asked:

- how do I create specialized child agents?

Lesson 5 asks:

- once I have a specialized child, what information should stay inside that child's domain?

That difference matters.

If the CEO stored the full technical roadmap, full hiring intent, and all architecture notes, then the CTO would exist in name only. The real technical boundary would not actually exist.

Instead:

- the CTO stores `technical_roadmap`
- the CTO stores `hiring_intent`
- the CTO stores `architecture_decisions`
- the CEO stores `executive_updates`

That is a cleaner company structure and a cleaner Jido model.

## Trying It Out

Run the lesson:

```bash
cd 05_hire_a_cto
mix deps.get
mix test
```

If your shell is not already resolving asdf shims first:

```bash
PATH="$HOME/.asdf/shims:$HOME/.asdf/bin:$PATH" mix test
```

You can also inspect the flow in `iex`:

```bash
PATH="$HOME/.asdf/shims:$HOME/.asdf/bin:$PATH" iex -S mix
```

Then:

```elixir
alias HireEngineerAndBuild.{CEOAgent, StudioJido}
alias Jido.{AgentServer, Signal}

{:ok, pid} = StudioJido.start_agent(CEOAgent, id: "ceo-1")

{:ok, _ceo} =
  AgentServer.call(
    pid,
    Signal.new!("studio.technical_leadership_requested", %{}, source: "/ceo")
  )

{:ok, parent_state} = AgentServer.state(pid)
cto_pid = parent_state.children.cto.pid

{:ok, _cto} =
  AgentServer.call(
    cto_pid,
    Signal.new!(
      "cto.technical_strategy_requested",
      %{milestone: "vertical slice", product_goal: "make combat feel responsive"},
      source: "/ceo"
    )
  )

{:ok, ceo_state} = AgentServer.state(pid)
{:ok, cto_state} = AgentServer.state(cto_pid)

ceo_state.agent.state
cto_state.agent.state
```

You should see a clear split:

- the CEO state contains a concise executive update
- the CTO state contains the actual technical roadmap and hiring intent

## What the Tests Prove

The lesson 5 tests in [`test/hire_engineer_and_build_test.exs`](./test/hire_engineer_and_build_test.exs) prove two behaviors:

- the CEO can spawn the CTO as the technical boundary of the company
- the CTO can own detailed technical planning while reporting only an executive summary back to the CEO

That second test is the real lesson.

It proves the architecture is not just hierarchical, but also **layered by decision scope**.

## Why This Matters

This pattern becomes more important as the company grows:

- the CEO should not hold engineer-level execution state
- the CTO should not need to push every internal technical note upward
- later, the engineering manager should not need to carry the CEO’s concerns either

Each layer should own its own level of abstraction.

Jido does not enforce that rule for you. But the framework makes it natural when you model agents by domain responsibility instead of just by process count.

## Jido Takeaway

A useful multi-agent system is not just a set of running processes.

It is a set of **bounded decision surfaces**.

Lesson 5 uses the CTO to teach that idea:

- the CTO owns technical planning
- the CEO receives only the outcome summary
- the technical boundary becomes real in both code and state shape

## What the Studio Can Do Now

The studio can now:

- run a CEO as the top company owner
- spawn a CTO as the technical domain owner
- let the CTO produce milestone-level technical planning
- keep detailed technical state inside the CTO
- aggregate only executive-level technical updates at the CEO layer

The startup now has the beginning of a real technical leadership chain.

## What Still Hurts

The CTO can own technical direction, but there is still nobody managing day-to-day engineering execution.

There is no engineering manager yet.
There are no engineer agents yet.
There is still no recurring delivery loop.

That is the next stage of growth.

## Next Lesson

In [`06_engineering_org`](../06_engineering_org/README.md), we will introduce the `EngineeringManagerAgent`, add engineers beneath that layer, and teach fan-out and result aggregation without pulling recurring cadence into the same chapter.
