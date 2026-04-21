defmodule AIStudioMode.Actions.RecordProductAlignmentReceived do
  @moduledoc """
  Stores the PM's AI-assisted alignment packet and finalizes a company packet when possible.
  """

  alias AIStudioMode.Alignment

  use Jido.Action,
    name: "record_product_alignment_received",
    description: "Stores the PM packet at the CEO layer",
    schema: [
      round: [type: :integer, required: true],
      product_brief: [type: :string, required: true],
      design_direction: [type: :string, required: true],
      qa_summary: [type: :string, required: true],
      status: [type: :string, required: true]
    ]

  @impl true
  def run(params, context) do
    product_updates = Map.get(context.state, :product_updates, [])
    updates = %{product_updates: product_updates ++ [params]}

    {:ok,
     Map.merge(
       updates,
       Alignment.maybe_complete_company_alignment(Map.merge(context.state, updates), params.round)
     )}
  end
end
