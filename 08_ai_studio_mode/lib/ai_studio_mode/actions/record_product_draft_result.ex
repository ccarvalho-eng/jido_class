defmodule AIStudioMode.Actions.RecordProductDraftResult do
  @moduledoc """
  Stores the PM's local AI brief and emits a product packet when all drafts exist.
  """

  alias AIStudioMode.Alignment

  use Jido.Action,
    name: "record_product_draft_result",
    description: "Stores the PM AI brief for the current round",
    schema: [
      status: [type: :atom, required: true],
      result: [type: :map],
      reason: [type: :any],
      instruction: [type: :any],
      meta: [type: :map, default: %{}]
    ]

  @impl true
  def run(%{status: :ok, result: %{text: text}, meta: %{round: round}}, context) do
    product_briefs = Map.get(context.state, :product_briefs, [])
    updates = %{product_briefs: product_briefs ++ [%{round: round, text: text}]}

    {alignment_updates, directives} =
      Alignment.maybe_complete_product_alignment(
        Map.merge(context.state, updates),
        round,
        context.agent
      )

    {:ok, Map.merge(updates, alignment_updates), directives}
  end

  def run(%{status: :error, reason: reason, meta: %{round: round}}, _context) do
    {:error,
     Jido.Error.execution_error("Product AI draft failed", round: round, reason: inspect(reason))}
  end
end
