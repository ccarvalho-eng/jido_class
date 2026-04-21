defmodule ProductDesignQaRhythm.Actions.RecordRhythmChildStarted do
  @moduledoc """
  Records child startup and arms the first review cycle once the team is online.
  """

  alias ProductDesignQaRhythm.Cadence

  use Jido.Action,
    name: "record_rhythm_child_started",
    description: "Stores designer and QA startup events",
    schema: [
      child_id: [type: :string, required: true],
      tag: [type: :any, required: true]
    ]

  @impl true
  def run(%{child_id: child_id, tag: tag}, context) do
    {updates, directives} = Cadence.child_started(context.state, child_id, tag)
    {:ok, updates, directives}
  end
end
