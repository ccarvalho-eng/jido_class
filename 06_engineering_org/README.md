# Lesson 06: The CTO Builds an Engineering Org

By lesson 5, the startup finally had technical leadership.

That solved one problem and exposed another.

The CTO can own architecture focus and hiring intent, but a CTO alone still does not create execution capacity. Real work still needs to be delegated, coordinated, and rolled back up into something leadership can act on.

This chapter introduces the first real engineering org beneath the CTO.

## What You'll Learn

By the end of this lesson, you should understand:

- how one technical leader can delegate execution to a manager layer
- how an `EngineeringManagerAgent` can fan work out to multiple child agents
- how specialized `EngineerAgent`s can keep narrow local state
- how child reports can be aggregated back into one milestone-level snapshot
- how to separate technical direction from execution coordination inside a Jido hierarchy

## The Story

The studio now has a CEO, support functions, and a CTO.

That is enough structure to make plans. It is not enough structure to deliver them.

At this stage in a real startup, the next hire is rarely another executive. It is the first real execution layer beneath technical leadership:

- the CTO sets direction
- the engineering manager coordinates delivery
- engineers own scoped implementation work

That is the exact progression this lesson models.

The chapter deliberately does **not** introduce product cadence, QA pressure, or recurring loops yet. The company first needs a believable delivery structure before it can learn rhythm.

## The Jido Concept

Lesson 5 taught a vertical boundary:

- the CTO owns technical thinking
- the CEO only receives a summary

Lesson 6 teaches a horizontal execution pattern inside that technical domain:

> one agent fans work out to multiple specialists, then aggregates their results back up.

That means each layer has a different responsibility:

- `CTOAgent` owns the execution layer as a capability of the technical org
- `EngineeringManagerAgent` owns delegation and aggregation
- `EngineerAgent` owns one narrow discipline and one local unit of work at a time

This is the first lesson where the hierarchy starts behaving like a team rather than a chain of approvals.

## What We're Building

This chapter adds:

- `EngineeringOrg.StudioJido`
- `EngineeringOrg.CTOAgent`
- `EngineeringOrg.EngineeringManagerAgent`
- `EngineeringOrg.EngineerAgent`

The CTO will:

- receive `studio.execution_layer_requested`
- spawn an engineering manager
- record execution-layer startup events
- store milestone snapshots aggregated back from the engineering manager

The engineering manager will:

- receive `engineering.team_bootstrap_requested`
- spawn a gameplay engineer and a UI engineer
- record engineer startup events
- collect engineer task-completion reports
- emit a single milestone delivery snapshot back to the CTO when all expected work is in

The engineers will:

- receive `engineer.task_assigned`
- record local assigned work and completed deliverables
- emit one completion report back to the engineering manager

## The Code

The lesson’s code lives in:

- [`lib/engineering_org/cto_agent.ex`](./lib/engineering_org/cto_agent.ex)
- [`lib/engineering_org/engineering_manager_agent.ex`](./lib/engineering_org/engineering_manager_agent.ex)
- [`lib/engineering_org/engineer_agent.ex`](./lib/engineering_org/engineer_agent.ex)
- [`lib/engineering_org/actions/request_execution_layer.ex`](./lib/engineering_org/actions/request_execution_layer.ex)
- [`lib/engineering_org/actions/record_execution_child_started.ex`](./lib/engineering_org/actions/record_execution_child_started.ex)
- [`lib/engineering_org/actions/bootstrap_engineering_team.ex`](./lib/engineering_org/actions/bootstrap_engineering_team.ex)
- [`lib/engineering_org/actions/record_engineer_child_started.ex`](./lib/engineering_org/actions/record_engineer_child_started.ex)
- [`lib/engineering_org/actions/complete_assigned_task.ex`](./lib/engineering_org/actions/complete_assigned_task.ex)
- [`lib/engineering_org/actions/record_engineer_task_completed.ex`](./lib/engineering_org/actions/record_engineer_task_completed.ex)
- [`lib/engineering_org/actions/record_milestone_delivery_snapshot.ex`](./lib/engineering_org/actions/record_milestone_delivery_snapshot.ex)

The CTO still starts by creating the next layer down:

```elixir
defmodule EngineeringOrg.Actions.RequestExecutionLayer do
  alias EngineeringOrg.EngineeringManagerAgent
  alias Jido.Agent.Directive

  use Jido.Action,
    name: "request_execution_layer",
    description: "Spawns the engineering manager under the CTO",
    schema: []

  def run(_params, _context) do
    directive = Directive.spawn_agent(EngineeringManagerAgent, :engineering_manager)
    {:ok, %{execution_team: ["engineering_manager"]}, [directive]}
  end
end
```

That gets the execution layer online, but it is not the main point of the chapter.

The engineering manager’s bootstrap action is where the lesson starts teaching something new:

```elixir
defmodule EngineeringOrg.Actions.BootstrapEngineeringTeam do
  alias EngineeringOrg.EngineerAgent
  alias Jido.Agent.Directive

  use Jido.Action,
    name: "bootstrap_engineering_team",
    description: "Spawns a small engineering team for the current milestone",
    schema: [
      milestone: [type: :string, required: true]
    ]

  def run(%{milestone: milestone}, _context) do
    directives = [
      Directive.spawn_agent(EngineerAgent, :gameplay_engineer,
        opts: %{initial_state: %{discipline: "gameplay"}}
      ),
      Directive.spawn_agent(EngineerAgent, :ui_engineer,
        opts: %{initial_state: %{discipline: "ui"}}
      )
    ]

    {:ok,
     %{
       active_milestone: milestone,
       expected_disciplines: ["gameplay", "ui"],
       completed_reports: []
     }, directives}
  end
end
```

That one action fans out from one manager to two specialized workers.

## Why Initial State Matters Here

This lesson uses `initial_state` during `spawn_agent/3` for a reason.

The two engineers are instances of the same module, but they are not generic copies. Each one is born with a different discipline:

- `gameplay`
- `ui`

That lets the chapter teach a practical Jido pattern:

> one agent module can represent a role family, while child instances differentiate themselves through startup state.

That is more realistic than making a separate module for every tiny role variant.

## Aggregation Is The Real Lesson

The engineering manager is not interesting because it can spawn children. Lesson 4 already taught spawning.

The engineering manager is interesting because it can wait for multiple children and turn their individual reports into one higher-level snapshot.

The aggregation action does exactly that:

```elixir
defmodule EngineeringOrg.Actions.RecordEngineerTaskCompleted do
  alias Jido.Agent.Directive
  alias Jido.Signal

  use Jido.Action,
    name: "record_engineer_task_completed",
    description: "Aggregates engineer reports under the engineering manager",
    schema: [
      discipline: [type: :string, required: true],
      task: [type: :string, required: true],
      deliverable: [type: :string, required: true]
    ]

  def run(params, context) do
    reports = Map.get(context.state, :completed_reports, [])
    milestone = Map.get(context.state, :active_milestone)
    expected_disciplines = Map.get(context.state, :expected_disciplines, [])
    updated_reports = reports ++ [params]

    directive =
      maybe_emit_snapshot(updated_reports, expected_disciplines, milestone, context.agent)

    {:ok, %{completed_reports: updated_reports}, List.wrap(directive)}
  end
end
```

That is the engineering-manager idea in one place:

- collect worker results
- decide when the set is complete
- emit a milestone-level view upward

## Trying It Out

Run the lesson:

```bash
cd 06_engineering_org
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
alias EngineeringOrg.{CTOAgent, StudioJido}
alias Jido.{AgentServer, Signal}

wait_until = fn fun ->
  Enum.reduce_while(1..20, nil, fn _, _ ->
    case fun.() do
      nil ->
        Process.sleep(50)
        {:cont, nil}

      value ->
        {:halt, value}
    end
  end)
end

{:ok, cto_pid} = StudioJido.start_agent(CTOAgent, id: "cto-1")

{:ok, _cto} =
  AgentServer.call(
    cto_pid,
    Signal.new!("studio.execution_layer_requested", %{}, source: "/cto")
  )

cto_state =
  wait_until.(fn ->
    {:ok, state} = AgentServer.state(cto_pid)
    if Map.has_key?(state.children, :engineering_manager), do: state
  end)

manager_pid = cto_state.children.engineering_manager.pid

{:ok, _manager} =
  AgentServer.call(
    manager_pid,
    Signal.new!("engineering.team_bootstrap_requested", %{milestone: "vertical slice"}, source: "/cto")
  )

manager_state =
  wait_until.(fn ->
    {:ok, state} = AgentServer.state(manager_pid)

    if Map.has_key?(state.children, :gameplay_engineer) and Map.has_key?(state.children, :ui_engineer) do
      state
    end
  end)

gameplay_pid = manager_state.children.gameplay_engineer.pid
ui_pid = manager_state.children.ui_engineer.pid

AgentServer.call(
  gameplay_pid,
  Signal.new!(
    "engineer.task_assigned",
    %{task: "combat timing pass", deliverable: "combat loop feels responsive"},
    source: "/engineering_manager"
  )
)

AgentServer.call(
  ui_pid,
  Signal.new!(
    "engineer.task_assigned",
    %{task: "hud readability pass", deliverable: "combat hud is legible"},
    source: "/engineering_manager"
  )
)

{:ok, final_cto_state} = AgentServer.state(cto_pid)
final_cto_state.agent.state
```

The final CTO state should hold one milestone snapshot rather than two scattered engineer reports.

## What the Tests Prove

The lesson 6 tests in [`test/engineering_org_test.exs`](./test/engineering_org_test.exs) prove two things:

- the CTO can add an engineering manager as the first execution-layer child
- the engineering manager can fan work out to multiple engineers and aggregate the finished work back into one CTO-facing snapshot

That second behavior is the core of the lesson.

Without aggregation, the engineering manager would only be a message relay.

With aggregation, the engineering manager becomes a genuine coordination role.

## Why This Matters

This chapter makes the startup feel much more like a real technical organization.

The CTO does not need to manage every engineer task directly.
The engineers do not need to report every low-level completion straight to the CTO.

Instead:

- the CTO owns direction
- the engineering manager owns coordination
- engineers own execution

That is a meaningful organizational boundary and a meaningful Jido modeling boundary.

## Jido Takeaway

Multi-agent systems get interesting when one layer stops being a direct worker and starts becoming an aggregator.

Lesson 6 uses the engineering manager to teach that:

- spawn multiple specialized workers
- collect their results
- emit one summarized view upward

That is the heart of fan-out and aggregation in a runtime hierarchy.

## What the Studio Can Do Now

The studio can now:

- run a CTO with a true execution layer beneath it
- spawn an engineering manager
- let the engineering manager create a specialized engineer team
- keep engineer-local execution state inside the worker agents
- roll multiple engineer completions up into one milestone snapshot

The technical org now feels like a real delivery system rather than a planner with subordinates.

## What Still Hurts

The company can now execute technical work, but it still does not have the recurring cross-functional loop that makes a startup feel like an actual studio.

There is still no dedicated product role.
There is still no design role.
There is still no QA or playtest pressure.
There is still no recurring rhythm around planning, validation, and feedback.

That is the next stage of growth.

## Next Lesson

[`07_product_design_qa_rhythm`](../07_product_design_qa_rhythm/README.md) adds product, design, and QA to the picture. That is where the studio stops being only an engineering machine and starts behaving like a real game team with recurring planning, playtest, and feedback loops.
