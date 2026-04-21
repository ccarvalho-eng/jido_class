defmodule ProductDesignQaRhythm.Actions.RequestDeliveryRhythm do
  @moduledoc """
  Brings the cross-functional product loop online.
  """

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

  @impl true
  def run(
        %{milestone: milestone, player_promise: player_promise, target_cycles: target_cycles},
        _context
      ) do
    directives = [
      Directive.spawn_agent(DesignerAgent, :designer),
      Directive.spawn_agent(QAAgent, :qa)
    ]

    {:ok,
     %{
       active_milestone: milestone,
       player_promise: player_promise,
       target_cycles: target_cycles,
       review_cycles_completed: 0,
       cadence_started: false,
       cadence_events: [%{cycle: 0, stage: "delivery_rhythm_requested"}],
       cycle_reviews: %{},
       review_history: []
     }, directives}
  end
end
