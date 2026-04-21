defmodule AIStudioMode.Actions.RequestAIPlanningRound do
  @moduledoc """
  Starts one AI-assisted planning round across the CTO and product side.
  """

  alias AIStudioMode.StudioJido
  alias Jido.Agent.Directive
  alias Jido.Signal

  use Jido.Action,
    name: "request_ai_planning_round",
    description: "Sends one planning request to the CTO and product manager",
    schema: [
      round: [type: :integer, required: true],
      milestone: [type: :string, required: true],
      player_promise: [type: :string, required: true]
    ]

  @impl true
  def run(%{round: round, milestone: milestone, player_promise: player_promise}, context) do
    registry = Map.get(context.state, :child_registry, %{})
    payload = %{round: round, milestone: milestone, player_promise: player_promise}

    directives =
      [
        emit_child_request(registry["cto"], "cto.ai_strategy_requested", payload),
        emit_child_request(registry["product_manager"], "product.ai_brief_requested", payload)
      ]
      |> Enum.reject(&is_nil/1)

    {:ok, %{}, directives}
  end

  defp emit_child_request(nil, _signal_type, _payload), do: nil

  defp emit_child_request(child_id, signal_type, payload) do
    case StudioJido.whereis(child_id) do
      pid when is_pid(pid) ->
        signal = Signal.new!(signal_type, payload, source: "/ceo")
        Directive.emit_to_pid(signal, pid)

      _missing ->
        nil
    end
  end
end
