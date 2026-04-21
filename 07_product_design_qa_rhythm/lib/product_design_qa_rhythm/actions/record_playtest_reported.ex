defmodule ProductDesignQaRhythm.Actions.RecordPlaytestReported do
  @moduledoc """
  Stores a playtest result and advances the cadence when the cycle is complete.
  """

  alias ProductDesignQaRhythm.Cadence

  use Jido.Action,
    name: "record_playtest_reported",
    description: "Stores playtest feedback for the current review cycle",
    schema: [
      cycle: [type: :integer, required: true],
      finding: [type: :string, required: true],
      risk: [type: :string, required: true]
    ]

  @impl true
  def run(params, context) do
    {updates, directives} = Cadence.record_playtest_report(context.state, params)
    {:ok, updates, directives}
  end
end
