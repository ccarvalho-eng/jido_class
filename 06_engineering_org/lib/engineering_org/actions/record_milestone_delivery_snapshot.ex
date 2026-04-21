defmodule EngineeringOrg.Actions.RecordMilestoneDeliverySnapshot do
  @moduledoc """
  Stores the engineering manager's aggregated milestone snapshot at the CTO layer.
  """

  use Jido.Action,
    name: "record_milestone_delivery_snapshot",
    description: "Stores an aggregated execution snapshot from the engineering manager",
    schema: [
      milestone: [type: :string, required: true],
      engineers_completed: [type: :integer, required: true],
      disciplines: [type: {:list, :string}, required: true],
      status: [type: :string, required: true]
    ]

  @impl true
  def run(params, context) do
    snapshots = Map.get(context.state, :milestone_snapshots, [])
    {:ok, %{milestone_snapshots: snapshots ++ [params]}}
  end
end
