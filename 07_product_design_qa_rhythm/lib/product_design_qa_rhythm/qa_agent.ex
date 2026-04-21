defmodule ProductDesignQaRhythm.QAAgent do
  @moduledoc """
  QA agent for lesson 7.

  This agent runs repeated playtest passes and reports findings back to product.
  """

  use Jido.Agent,
    name: "qa",
    description: "Runs playtest passes and reports player risk",
    default_plugins: false,
    schema: [
      playtest_runs: [type: {:list, :map}, default: []]
    ]

  def signal_routes(_ctx) do
    [
      {"qa.review_cycle_requested", ProductDesignQaRhythm.Actions.RunPlaytestRound}
    ]
  end
end
