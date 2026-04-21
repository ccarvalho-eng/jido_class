defmodule SpawnBackofficeAndRecruiter.RecruiterAgent do
  @moduledoc """
  Recruiting support agent for lesson 4.
  """

  use Jido.Agent,
    name: "recruiter",
    description: "Starts role searches and reports them back to the CEO",
    default_plugins: false,
    schema: [
      open_roles: [type: {:list, :string}, default: []]
    ]

  def signal_routes(_ctx) do
    [
      {"recruiter.role_opened", SpawnBackofficeAndRecruiter.Actions.StartRoleSearch}
    ]
  end
end
