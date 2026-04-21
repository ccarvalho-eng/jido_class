# Lesson 07: Product, Design, and QA Give the Studio a Rhythm

By this point the studio has leadership, support functions, and an engineering org that can execute.

What it still lacks is rhythm.

Real startups do not move forward through one-off commands forever. They repeat:

- planning reviews
- design passes
- playtests
- feedback loops
- course corrections

This chapter is where the company starts to feel like a real game team.

## What You'll Learn

By the end of this lesson, you will have seen:

- how a `ProductManagerAgent` can own a repeated cross-functional loop
- how scheduling can drive recurring runtime behavior instead of a single burst of work
- how `DesignerAgent` and `QAAgent` can stay narrow while still shaping the outcome
- how repeated cycles become easier to debug when the agent state keeps a visible cadence trail
- how a review history can make a running workflow inspectable instead of opaque

## The Story

The CEO is no longer the default product owner.

That is a healthy sign. The company is finally large enough for product thinking, player experience, and quality feedback to become their own disciplines.

At this stage, a believable startup starts asking different questions:

- what player promise are we trying to protect?
- what does design need to improve next?
- what are playtests telling us?
- are we getting better from one cycle to the next?

Those questions are not about hierarchy. They are about rhythm.

That is why this lesson puts the `ProductManagerAgent` at the center. The PM does not replace the CTO or the engineering manager. The PM owns the repeated loop that turns feedback into the next round of decisions.

## The Jido Concept

Lesson 6 taught fan-out and aggregation inside the engineering org.

Lesson 7 teaches a different runtime pattern:

> a workflow that repeats over time, stays inspectable while it runs, and leaves behind a history you can reason about.

The key move in this chapter is not just spawning children. It is using scheduling to keep the loop alive:

- the product manager brings designer and QA online
- the product manager arms the first review cycle
- each finished cycle schedules the next one
- the workflow stops cleanly when the target number of cycles is done

This is also the first lesson where visibility is part of the design. The PM keeps:

- a cadence event log
- raw design feedback
- raw playtest reports
- a higher-level review history

That state is what makes the running loop understandable.

## What This Chapter Adds

This lesson introduces:

- `ProductDesignQaRhythm.StudioJido`
- `ProductDesignQaRhythm.ProductManagerAgent`
- `ProductDesignQaRhythm.DesignerAgent`
- `ProductDesignQaRhythm.QAAgent`

The product manager will:

- receive `studio.delivery_rhythm_requested`
- spawn design and QA support
- arm the first review cycle when both children are online
- schedule follow-up review cycles
- keep a visible history of what happened across the loop

The designer will:

- receive `design.review_cycle_requested`
- produce one focused design response for the current cycle
- report it back to product

The QA agent will:

- receive `qa.review_cycle_requested`
- produce one playtest report for the current cycle
- report it back to product

## The Code

The lesson’s code lives in:

- [`lib/product_design_qa_rhythm/product_manager_agent.ex`](./lib/product_design_qa_rhythm/product_manager_agent.ex)
- [`lib/product_design_qa_rhythm/designer_agent.ex`](./lib/product_design_qa_rhythm/designer_agent.ex)
- [`lib/product_design_qa_rhythm/qa_agent.ex`](./lib/product_design_qa_rhythm/qa_agent.ex)
- [`lib/product_design_qa_rhythm/cadence.ex`](./lib/product_design_qa_rhythm/cadence.ex)
- [`lib/product_design_qa_rhythm/actions/request_delivery_rhythm.ex`](./lib/product_design_qa_rhythm/actions/request_delivery_rhythm.ex)
- [`lib/product_design_qa_rhythm/actions/record_rhythm_child_started.ex`](./lib/product_design_qa_rhythm/actions/record_rhythm_child_started.ex)
- [`lib/product_design_qa_rhythm/actions/run_review_cycle.ex`](./lib/product_design_qa_rhythm/actions/run_review_cycle.ex)
- [`lib/product_design_qa_rhythm/actions/record_design_review_ready.ex`](./lib/product_design_qa_rhythm/actions/record_design_review_ready.ex)
- [`lib/product_design_qa_rhythm/actions/record_playtest_reported.ex`](./lib/product_design_qa_rhythm/actions/record_playtest_reported.ex)
- [`lib/product_design_qa_rhythm/actions/prepare_design_review.ex`](./lib/product_design_qa_rhythm/actions/prepare_design_review.ex)
- [`lib/product_design_qa_rhythm/actions/run_playtest_round.ex`](./lib/product_design_qa_rhythm/actions/run_playtest_round.ex)

The product manager starts the loop by bringing the cross-functional team online:

```elixir
defmodule ProductDesignQaRhythm.Actions.RequestDeliveryRhythm do
  alias Jido.Agent.Directive
  alias ProductDesignQaRhythm.{DesignerAgent, QAAgent}

  use Jido.Action,
    name: "request_delivery_rhythm",
    description: "Spawns design and QA support for a recurring product loop",
    schema: [
      milestone: [type: :string, required: true],
      player_promise: [type: :string, required: true],
      target_cycles: [type: :integer, default: 2]
    ]

  def run(%{milestone: milestone, player_promise: player_promise, target_cycles: target_cycles}, _context) do
    directives = [
      Directive.spawn_agent(DesignerAgent, :designer),
      Directive.spawn_agent(QAAgent, :qa)
    ]

    {:ok,
     %{
       active_milestone: milestone,
       player_promise: player_promise,
       target_cycles: target_cycles,
       cadence_events: [%{cycle: 0, stage: "delivery_rhythm_requested"}]
     }, directives}
  end
end
```

That brings the right people into the room. It does not start the rhythm yet.

The first scheduled cycle is armed only after both children are actually online:

```elixir
signal =
  Signal.new!("product.review_cycle_tick", %{cycle: 1}, source: "/product_manager")

Directive.schedule(10, signal)
```

That is the chapter’s first important runtime move. The next step in the workflow is described declaratively, and the runtime delivers it later.

## Why The Product Manager Owns The Loop

The PM is the right coordinator for this lesson because the work is not purely technical anymore.

The PM is holding together three kinds of truth at once:

- the milestone
- the player promise
- the feedback coming back from design and QA

The PM is not doing the design work or the QA work directly. The PM is deciding when a cycle has enough information to move forward.

That makes this role a good teaching surface for repeated workflows:

- the designer stays focused on experience
- QA stays focused on player risk
- product decides when a cycle is complete and whether another one should start

## The Cadence Trail

This lesson keeps a deliberate paper trail in agent state.

The product manager records:

- `cadence_events` for the live sequence of events
- `design_feedback` for raw design responses
- `playtest_reports` for raw QA findings
- `review_history` for cycle-level snapshots

That is what makes the lesson observable.

Instead of staring at a running process and guessing, you can inspect the state and answer concrete questions:

- how many cycles ran?
- what happened in cycle 1 versus cycle 2?
- when did the loop arm itself?
- what changed after the first playtest report?

## Trying It Out

Run the lesson:

```bash
cd 07_product_design_qa_rhythm
mix deps.get
mix test
```

If your shell is not already resolving asdf shims first:

```bash
PATH="$HOME/.asdf/shims:$HOME/.asdf/bin:$PATH" mix test
```

You can also inspect the rhythm live in `iex`:

```bash
PATH="$HOME/.asdf/shims:$HOME/.asdf/bin:$PATH" iex -S mix
```

Then:

```elixir
alias Jido.{AgentServer, Signal}
alias ProductDesignQaRhythm.{ProductManagerAgent, StudioJido}

wait_until = fn fun ->
  Enum.reduce_while(1..40, nil, fn _, _ ->
    case fun.() do
      nil ->
        Process.sleep(50)
        {:cont, nil}

      value ->
        {:halt, value}
    end
  end)
end

{:ok, pm_pid} = StudioJido.start_agent(ProductManagerAgent, id: "pm-1")

{:ok, _pm} =
  AgentServer.call(
    pm_pid,
    Signal.new!(
      "studio.delivery_rhythm_requested",
      %{
        milestone: "vertical slice",
        player_promise: "make the first ten minutes readable and sticky",
        target_cycles: 2
      },
      source: "/ceo"
    )
  )

final_state =
  wait_until.(fn ->
    {:ok, state} = AgentServer.state(pm_pid)

    if state.agent.state.review_cycles_completed == 2 do
      state
    end
  end)

final_state.agent.state
```

The final product-manager state should show two finished review cycles, along with the event trail and the review history that got the team there.

## What the Tests Prove

The lesson 7 tests in [`test/product_design_qa_rhythm_test.exs`](./test/product_design_qa_rhythm_test.exs) prove two things:

- the product manager can bring design and QA online and arm the first cycle only after the team is actually ready
- repeated scheduled cycles leave behind a visible history across product, design, and QA instead of disappearing into runtime noise

That second point is the real lesson.

The workflow is not only running. It is inspectable.

## Why This Matters

A startup stops feeling like a collection of roles and starts feeling like an operating company when the loops repeat.

That is the jump this lesson makes.

The company now has a way to:

- frame a milestone around a player promise
- ask design for a response
- ask QA for player risk
- complete one cycle
- run another cycle with new information

This is also the point where visibility becomes part of product quality. If no one can tell what happened between cycles, the workflow might exist, but it will be hard to trust.

## Jido Takeaway

Recurring workflows become much easier to model when the next step is emitted as runtime intent instead of hidden in process code.

Lesson 7 uses that idea in a small, concrete way:

- schedule the next cycle
- let specialized agents do their part
- keep a visible trail while the loop is running
- stop when the planned cadence is complete

That combination of scheduling and inspectable state is what makes this chapter different from the org-building lessons before it.

## What the Studio Can Do Now

The studio can now:

- run a recurring product loop instead of a one-off workflow
- let product, design, and QA each own a narrow part of the cycle
- keep a design history and a playtest history
- preserve a cycle-by-cycle review log that leadership can inspect later

The game team finally has a rhythm.

## What Still Hurts

The studio now has a believable operating loop, but one big ingredient is still missing.

AI is not involved yet.

That is deliberate.

The company now makes sense on its own terms, with human-style role boundaries and inspectable runtime behavior. That makes it the right moment to add AI without letting AI become the explanation for everything.

## Next Lesson

[`08_ai_studio_mode`](../08_ai_studio_mode/README.md) adds AI on top of the structure the studio already earned. The final chapter keeps the same company shape and uses AI as an augmentation layer for planning, drafting, and summarizing.
