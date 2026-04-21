defmodule SpawnBackofficeAndRecruiter.CEOAgent do
  @moduledoc """
  CEO agent for lesson 4.

  The founder is now acting as the CEO and starts delegating operations and
  recruiting work to child agents.
  """

  use Jido.Agent,
    name: "ceo",
    description: "CEO who delegates support work to child agents",
    default_plugins: false,
    schema: [
      studio_name: [type: :string, default: "Starboard Studio"],
      current_priority: [type: :string, default: "hire the first engineer"],
      support_team: [type: {:list, :string}, default: []],
      support_team_boot_events: [type: {:list, :map}, default: []],
      recruiting_updates: [type: {:list, :map}, default: []],
      backoffice_updates: [type: {:list, :map}, default: []]
    ]

  def signal_routes(_ctx) do
    [
      {"studio.support_team_requested", SpawnBackofficeAndRecruiter.Actions.RequestSupportTeam},
      {"jido.agent.child.started", SpawnBackofficeAndRecruiter.Actions.RecordChildStarted},
      {"studio.role_search_started", SpawnBackofficeAndRecruiter.Actions.RecordRoleSearchStarted},
      {"studio.hiring_constraints_prepared",
       SpawnBackofficeAndRecruiter.Actions.RecordHiringConstraintsPrepared}
    ]
  end
end
