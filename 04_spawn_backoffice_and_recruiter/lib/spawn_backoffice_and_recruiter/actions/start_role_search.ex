defmodule SpawnBackofficeAndRecruiter.Actions.StartRoleSearch do
  @moduledoc """
  Starts a recruiting search for a role and notifies the parent CEO.
  """

  alias Jido.Agent.Directive
  alias Jido.Signal

  use Jido.Action,
    name: "start_role_search",
    description: "Starts a role search in the recruiter agent",
    schema: [
      role: [type: :string, required: true]
    ]

  @impl true
  def run(%{role: role}, context) do
    open_roles = Map.get(context.state, :open_roles, [])

    signal =
      Signal.new!(
        "studio.role_search_started",
        %{role: role, status: "search_started"},
        source: "/recruiter"
      )

    directive = Directive.emit_to_parent(context.agent, signal)

    {:ok, %{open_roles: open_roles ++ [role]}, List.wrap(directive)}
  end
end
