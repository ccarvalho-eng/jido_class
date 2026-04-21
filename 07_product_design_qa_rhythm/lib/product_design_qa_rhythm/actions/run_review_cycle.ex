defmodule ProductDesignQaRhythm.Actions.RunReviewCycle do
  @moduledoc """
  Starts one cross-functional review cycle by asking design and QA for input.
  """

  alias Jido.Agent.Directive
  alias Jido.Signal
  alias ProductDesignQaRhythm.StudioJido

  use Jido.Action,
    name: "run_review_cycle",
    description: "Starts one review cycle across design and QA",
    schema: [
      cycle: [type: :integer, required: true]
    ]

  @impl true
  def run(%{cycle: cycle}, context) do
    milestone = Map.get(context.state, :active_milestone)
    player_promise = Map.get(context.state, :player_promise)
    registry = Map.get(context.state, :child_registry, %{})
    cadence_events = Map.get(context.state, :cadence_events, [])

    directives =
      [
        emit_review_request(registry["designer"], "design.review_cycle_requested", %{
          cycle: cycle,
          milestone: milestone,
          player_promise: player_promise
        }),
        emit_review_request(registry["qa"], "qa.review_cycle_requested", %{
          cycle: cycle,
          milestone: milestone,
          player_promise: player_promise
        })
      ]
      |> Enum.reject(&is_nil/1)

    updates = %{
      cadence_events: cadence_events ++ [%{cycle: cycle, stage: "review_cycle_started"}]
    }

    {:ok, updates, directives}
  end

  defp emit_review_request(nil, _type, _payload), do: nil

  defp emit_review_request(child_id, signal_type, payload) do
    case StudioJido.whereis(child_id) do
      pid when is_pid(pid) ->
        signal = Signal.new!(signal_type, payload, source: "/product_manager")
        Directive.emit_to_pid(signal, pid)

      _missing ->
        nil
    end
  end
end
