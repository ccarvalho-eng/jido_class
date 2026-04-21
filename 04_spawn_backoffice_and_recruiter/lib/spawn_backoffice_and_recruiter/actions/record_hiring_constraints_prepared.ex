defmodule SpawnBackofficeAndRecruiter.Actions.RecordHiringConstraintsPrepared do
  @moduledoc """
  Records that backoffice prepared the hiring constraints for a role.
  """

  use Jido.Action,
    name: "record_hiring_constraints_prepared",
    description: "Stores a backoffice update reported by the backoffice child",
    schema: [
      role: [type: :string, required: true],
      status: [type: :string, required: true],
      hiring_budget: [type: :integer, required: true]
    ]

  @impl true
  def run(params, context) do
    updates = Map.get(context.state, :backoffice_updates, [])
    {:ok, %{backoffice_updates: updates ++ [params]}}
  end
end
