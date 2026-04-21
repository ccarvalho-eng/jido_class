defmodule ProductDesignQaRhythm.Actions.RecordDesignReviewReady do
  @moduledoc """
  Stores a design review result and advances the cadence when the cycle is complete.
  """

  alias ProductDesignQaRhythm.Cadence

  use Jido.Action,
    name: "record_design_review_ready",
    description: "Stores design feedback for the current review cycle",
    schema: [
      cycle: [type: :integer, required: true],
      focus: [type: :string, required: true],
      artifact: [type: :string, required: true]
    ]

  @impl true
  def run(params, context) do
    {updates, directives} = Cadence.record_design_review(context.state, params)
    {:ok, updates, directives}
  end
end
