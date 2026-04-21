# Lesson 08: The Studio Becomes AI-Assisted

The studio is already coherent before AI arrives.

That is the whole point of this final chapter.

By now the company has:

- leadership
- support functions
- an engineering org
- a recurring product, design, and QA rhythm

This lesson does not replace that structure. It adds a new capability at the boundary, where outside help belongs.

## What You'll Learn

By the end of this lesson, you will have seen:

- how to keep model access behind an adapter boundary
- how to use `Directive.run_instruction/2` so AI work happens at runtime instead of inside core agent logic
- how role-specific AI drafts can stay inside clear company boundaries
- how one planning round can aggregate AI output without turning the whole studio into one giant prompt
- how to keep tests local and deterministic with a fake adapter while still supporting a real Ollama path

## The Story

The startup finally feels like a real company.

That is exactly when AI becomes useful.

Not because AI can invent the org chart, and not because AI can rescue unclear ownership, but because the studio now has stable roles that can each ask for help in a narrow way:

- the CTO wants a technical strategy draft
- the product manager wants a scope brief
- the designer wants a direction draft
- QA wants a concise playtest-risk summary

The CEO does not ask one model to run the whole company.

Instead, the CEO coordinates a planning round across existing roles, and those roles ask AI for help inside their own boundaries.

## The Jido Concept

This chapter introduces a different kind of runtime effect:

> an agent can ask the runtime to execute an instruction, then handle the result as a normal state transition.

That is what `Directive.run_instruction/2` gives us.

Jido’s own docs frame `RunInstruction` as an advanced runtime pattern, especially alongside strategies that want to keep `cmd/2` pure while external work executes elsewhere. That warning matters. Most ordinary actions should still do their work directly in `run/2`.

This chapter uses `RunInstruction` on purpose because model calls are slow, external, and operationally noisy. They are a good example of work that benefits from staying at the runtime boundary.

The agent stays pure:

- it decides that AI work should happen
- it emits a runtime instruction directive
- the runtime executes the instruction
- the result comes back through `cmd/2`

That makes the AI call explicit in the same way earlier lessons made spawning, scheduling, and signaling explicit.

## What This Chapter Adds

This lesson introduces:

- `AIStudioMode.StudioJido`
- `AIStudioMode.CEOAgent`
- `AIStudioMode.CTOAgent`
- `AIStudioMode.ProductManagerAgent`
- `AIStudioMode.DesignerAgent`
- `AIStudioMode.QAAgent`
- `AIStudioMode.Actions.GenerateRoleDraft`
- `AIStudioMode.AIAdapters.FakeAdapter`
- `AIStudioMode.AIAdapters.ReqLLMOllamaAdapter`

The flow is intentionally compact:

1. the CEO brings the AI-capable leadership tree online
2. the product manager brings design and QA online
3. the CEO starts one AI-assisted planning round
4. the CTO, product manager, designer, and QA each request one role-specific draft
5. product aggregates its three drafts into one product packet
6. the CEO combines that product packet with the CTO draft into one company-level alignment packet

## The Code

The lesson’s code lives in:

- [`lib/ai_studio_mode/ceo_agent.ex`](./lib/ai_studio_mode/ceo_agent.ex)
- [`lib/ai_studio_mode/cto_agent.ex`](./lib/ai_studio_mode/cto_agent.ex)
- [`lib/ai_studio_mode/product_manager_agent.ex`](./lib/ai_studio_mode/product_manager_agent.ex)
- [`lib/ai_studio_mode/designer_agent.ex`](./lib/ai_studio_mode/designer_agent.ex)
- [`lib/ai_studio_mode/qa_agent.ex`](./lib/ai_studio_mode/qa_agent.ex)
- [`lib/ai_studio_mode/ai_adapter.ex`](./lib/ai_studio_mode/ai_adapter.ex)
- [`lib/ai_studio_mode/ai_adapters/fake_adapter.ex`](./lib/ai_studio_mode/ai_adapters/fake_adapter.ex)
- [`lib/ai_studio_mode/ai_adapters/req_llm_ollama_adapter.ex`](./lib/ai_studio_mode/ai_adapters/req_llm_ollama_adapter.ex)
- [`lib/ai_studio_mode/actions/request_role_draft.ex`](./lib/ai_studio_mode/actions/request_role_draft.ex)
- [`lib/ai_studio_mode/actions/generate_role_draft.ex`](./lib/ai_studio_mode/actions/generate_role_draft.ex)
- [`lib/ai_studio_mode/actions/record_role_draft_result.ex`](./lib/ai_studio_mode/actions/record_role_draft_result.ex)

The key boundary is the draft request action:

```elixir
defmodule AIStudioMode.Actions.RequestRoleDraft do
  alias AIStudioMode.Prompts
  alias Jido.Agent.Directive
  alias Jido.Instruction

  use Jido.Action,
    name: "request_role_draft",
    description: "Starts one AI draft through RunInstruction",
    schema: [
      round: [type: :integer, required: true],
      milestone: [type: :string, required: true],
      player_promise: [type: :string, required: true]
    ]

  def run(%{round: round} = params, context) do
    role = Map.get(context.state, :role_name)

    instruction =
      Instruction.new!(%{
        action: AIStudioMode.Actions.GenerateRoleDraft,
        params: %{
          role: role,
          prompt: Prompts.build(role, params)
        }
      })

    directive =
      Directive.run_instruction(instruction,
        result_action: AIStudioMode.Actions.RecordRoleDraftResult,
        meta: %{round: round}
      )

    {:ok, %{}, [directive]}
  end
end
```

That is the core move of the lesson.

The role agent does not call the model directly. It describes the work, and the runtime executes it.

## Why The Adapter Matters

This chapter uses a tiny adapter boundary for one reason: the tutorial should be runnable even if no model server is available.

The default path in tests is:

- `FakeAdapter`
- deterministic output
- no network
- fast test runs

The real local path is:

- `ReqLLMOllamaAdapter`
- `req_llm`
- Ollama running locally

That lets the lesson show a real model integration without making the whole repo depend on a live service.

It also keeps the tutorial aligned with Jido’s broader design philosophy: AI is optional, and the company should still make sense when the model is unplugged.

## Optional Ollama Path

If you want to run the lesson against a real local model, install Ollama, pull a model such as `llama3`, and make sure the server is running.

Then start the CEO with an initial state that switches adapters:

```elixir
alias AIStudioMode.{CEOAgent, StudioJido}

{:ok, ceo_pid} =
  StudioJido.start_agent(CEOAgent,
    id: "ceo-ollama",
    initial_state: %{
      ai_adapter: AIStudioMode.AIAdapters.ReqLLMOllamaAdapter,
      ollama_model: "llama3",
      ollama_base_url: "http://localhost:11434/v1"
    }
  )
```

The child roles inherit those settings when the CEO and product manager spawn them.

## Trying It Out

Run the lesson:

```bash
cd 08_ai_studio_mode
mix deps.get
mix test
```

If your shell is not already resolving asdf shims first:

```bash
PATH="$HOME/.asdf/shims:$HOME/.asdf/bin:$PATH" mix test
```

You can also inspect one AI-assisted planning round in `iex`:

```bash
PATH="$HOME/.asdf/shims:$HOME/.asdf/bin:$PATH" iex -S mix
```

Then:

```elixir
alias AIStudioMode.{CEOAgent, StudioJido}
alias Jido.{AgentServer, Signal}

wait_until = fn fun ->
  Enum.reduce_while(1..60, nil, fn _, _ ->
    case fun.() do
      nil ->
        Process.sleep(50)
        {:cont, nil}

      value ->
        {:halt, value}
    end
  end)
end

{:ok, ceo_pid} =
  StudioJido.start_agent(CEOAgent,
    id: "ceo-1",
    initial_state: %{ai_adapter: AIStudioMode.AIAdapters.FakeAdapter}
  )

{:ok, _ceo} =
  AgentServer.call(
    ceo_pid,
    Signal.new!("studio.ai_staff_requested", %{}, source: "/ceo")
  )

{:ok, _ceo} =
  AgentServer.call(
    ceo_pid,
    Signal.new!(
      "studio.ai_planning_round_requested",
      %{
        round: 1,
        milestone: "vertical slice",
        player_promise: "make combat onboarding readable"
      },
      source: "/ceo"
    )
  )

final_state =
  wait_until.(fn ->
    {:ok, state} = AgentServer.state(ceo_pid)
    if length(state.agent.state.alignment_packets) == 1, do: state
  end)

final_state.agent.state.alignment_packets
```

You should see one final alignment packet that combines:

- the CTO draft
- the product brief
- the design direction
- the QA summary

## What the Tests Prove

The lesson 8 tests in [`test/ai_studio_mode_test.exs`](./test/ai_studio_mode_test.exs) prove two things:

- the CEO can bring the AI-capable org online and let the product manager add design and QA underneath it
- one AI-assisted planning round can aggregate technical and product alignment through runtime instructions instead of direct model calls inside the agents

That second test is the real lesson.

The AI work is real enough to demonstrate the shape, but the architecture stays in control.

## Why This Matters

The strongest AI lesson is not “look, the model returned text.”

The strongest AI lesson is:

- the org still makes sense
- the roles still make sense
- the runtime boundary is still explicit
- the model is helping, not hiding the design

That is what this chapter protects.

## Jido Takeaway

If an AI call is part of runtime work, it should look like runtime work.

`Directive.run_instruction/2` gives the tutorial a clean way to express that:

- describe the model call as an instruction
- let the runtime execute it
- fold the result back through normal state transitions

That keeps the AI boundary visible and keeps the agent logic honest.

## What the Studio Can Do Now

The studio can now:

- run a believable company structure without AI
- ask AI for narrow, role-specific help
- aggregate those drafts back into company-level planning
- swap between a fake adapter and a real local Ollama path

The company ends the series with AI assistance, not AI dependence.
