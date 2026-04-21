defmodule SpawnBackofficeAndRecruiter.Actions.RecordRoleSearchStarted do
  @moduledoc """
  Records that recruiting has started a role search.
  """

  use Jido.Action,
    name: "record_role_search_started",
    description: "Stores a recruiting update reported by the recruiter child",
    schema: [
      role: [type: :string, required: true],
      status: [type: :string, required: true]
    ]

  @impl true
  def run(params, context) do
    updates = Map.get(context.state, :recruiting_updates, [])
    {:ok, %{recruiting_updates: updates ++ [params]}}
  end
end
