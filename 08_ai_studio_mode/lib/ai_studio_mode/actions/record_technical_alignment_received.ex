defmodule AIStudioMode.Actions.RecordTechnicalAlignmentReceived do
  @moduledoc """
  Stores the CTO's AI-assisted technical alignment and finalizes a company packet when possible.
  """

  alias AIStudioMode.Alignment

  use Jido.Action,
    name: "record_technical_alignment_received",
    description: "Stores the CTO draft at the CEO layer",
    schema: [
      round: [type: :integer, required: true],
      technical_strategy: [type: :string, required: true],
      status: [type: :string, required: true]
    ]

  @impl true
  def run(params, context) do
    technical_updates = Map.get(context.state, :technical_updates, [])
    updates = %{technical_updates: technical_updates ++ [params]}

    {:ok,
     Map.merge(
       updates,
       Alignment.maybe_complete_company_alignment(Map.merge(context.state, updates), params.round)
     )}
  end
end
