defmodule ProductDesignQaRhythm.Actions.RunPlaytestRound do
  @moduledoc """
  Produces one QA report for the current review cycle.
  """

  alias Jido.Agent.Directive
  alias Jido.Signal

  use Jido.Action,
    name: "run_playtest_round",
    description: "Creates a playtest report for the current review cycle",
    schema: [
      cycle: [type: :integer, required: true],
      milestone: [type: :string, required: true],
      player_promise: [type: :string, required: true]
    ]

  @impl true
  def run(%{cycle: cycle, milestone: milestone, player_promise: player_promise}, context) do
    {finding, risk} =
      case cycle do
        1 -> {"players miss the promised hook in the first session", "high"}
        _ -> {"players lose combat readability once the screen gets busy", "medium"}
      end

    signal =
      Signal.new!(
        "product.playtest_reported",
        %{cycle: cycle, finding: finding, risk: risk},
        source: "/qa"
      )

    directive = Directive.emit_to_parent(context.agent, signal)

    run = %{
      cycle: cycle,
      milestone: milestone,
      player_promise: player_promise,
      finding: finding,
      risk: risk
    }

    {:ok, %{playtest_runs: Map.get(context.state, :playtest_runs, []) ++ [run]},
     List.wrap(directive)}
  end
end
