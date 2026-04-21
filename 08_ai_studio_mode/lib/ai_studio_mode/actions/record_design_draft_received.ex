defmodule AIStudioMode.Actions.RecordDesignDraftReceived do
  @moduledoc """
  Stores the designer draft and emits a product packet when all drafts exist.
  """

  alias AIStudioMode.Alignment

  use Jido.Action,
    name: "record_design_draft_received",
    description: "Stores the designer draft for the current round",
    schema: [
      round: [type: :integer, required: true],
      design_direction: [type: :string, required: true]
    ]

  @impl true
  def run(%{round: round, design_direction: text}, context) do
    design_directions = Map.get(context.state, :design_directions, [])
    updates = %{design_directions: design_directions ++ [%{round: round, text: text}]}

    {alignment_updates, directives} =
      Alignment.maybe_complete_product_alignment(
        Map.merge(context.state, updates),
        round,
        context.agent
      )

    {:ok, Map.merge(updates, alignment_updates), directives}
  end
end
