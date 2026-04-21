defmodule AIStudioMode.Actions.RecordQADraftReceived do
  @moduledoc """
  Stores the QA draft and emits a product packet when all drafts exist.
  """

  alias AIStudioMode.Alignment

  use Jido.Action,
    name: "record_qa_draft_received",
    description: "Stores the QA draft for the current round",
    schema: [
      round: [type: :integer, required: true],
      qa_summary: [type: :string, required: true]
    ]

  @impl true
  def run(%{round: round, qa_summary: text}, context) do
    qa_summaries = Map.get(context.state, :qa_summaries, [])
    updates = %{qa_summaries: qa_summaries ++ [%{round: round, text: text}]}

    {alignment_updates, directives} =
      Alignment.maybe_complete_product_alignment(
        Map.merge(context.state, updates),
        round,
        context.agent
      )

    {:ok, Map.merge(updates, alignment_updates), directives}
  end
end
